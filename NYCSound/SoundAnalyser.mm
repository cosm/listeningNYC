#import "SoundAnalyser.h"
#import "DBTool.h"
#import "maxiFFT.h"
#import "RadarSweeper.h"
#import "COSM.h"

template<typename T>
struct Normalizing {
    Normalizing() {
        min = std::numeric_limits<T>::max();
        max = std::numeric_limits<T>::min();
    }
    T max;
    T min;
    T currentValue;
    void set(T value) {
        if (value < min) { min = value; }
        if (value > max) { max = value; }
        currentValue = value;
    }
    float getNormalized () {
        float n = map(currentValue, min, max, 0.0f, 1.0f);
        return n;
    }
    T map(float input, T inputMin, T inputMax, float outputMin, float outputMax) {
        T output = ((input-inputMin)/(inputMax-inputMin)*(outputMax-outputMin)+outputMin);
        if (outputMax < outputMin) {
            if (output < outputMax) {
                output = outputMax;
            }
            else if (output > outputMin) {
                output = outputMin;
            }
        } else {
            if (output > outputMax) {
                output = outputMax;
            }
            else if (output < outputMin) {
                output = outputMin;
            }
        }
        return output;
    };
};

@interface SoundAnalyser () {
    maxiFFT *fftAWeighted;
    maxiFFTOctaveAnalyzer *octAWeighted;
    Normalizing<float> *nomalizedAWeighted;
    BOOL shouldResetMetering;
    NSInteger averages;
}

- (void)resetPeakLevels;

@end

@implementation SoundAnalyser

#pragma mark - Tools

@synthesize flatLevelMeter, aWeightedLevelMeter, cWeightedLevelMeter;

#pragma mark - Measure

@synthesize currentLevels;

- (void)resetMetering {
    shouldResetMetering = YES;
}

-(DBCollection)peakLevels {
    return peakLevels;
}

- (void)preformResetMetering {
    peakLevels.flatDB = -99999.9f;
    peakLevels.aWeightedDB = -99999.9f;
    peakLevels.cWeightedDB = -99999.9f;
    shouldResetMetering = false;
    
    if (fftAWeighted) {
        delete fftAWeighted;
        delete octAWeighted;
        delete nomalizedAWeighted;
    }
    
    fftAWeighted = new maxiFFT();
    octAWeighted = new maxiFFTOctaveAnalyzer();
    octAWeighted->peakDecayRate = 1.0;
    NSInteger fftSize = 1024 * 2;
    NSInteger windowSize = 1024; //1024;
    Float64 samplingRate = [Novocaine audioManager].samplingRate;
    fftAWeighted->setup(fftSize, windowSize, 256);
    NSLog(@"%d", averages);
    NSLog(@"%f", samplingRate);
    NSLog(@"%df", fftSize/2);
    octAWeighted->setup(samplingRate,
                        fftSize/2,
                        averages);
    //            for (int i=0; i<octAWeighted->nAverages; ++i) {
    //                if (i % averages == 0) {
    //                    lastBin = lastBin * 2.0f;
    //                    NSLog(@"Bin %d: %f  hz", i, lastBin);
    //                }
    //            }
    nomalizedAWeighted = new Normalizing<float>[octAWeighted->nAverages];
    shouldResetMetering = NO;
}

- (void)start {
    NSLog(@"Sound Analyers start");
    
    [self resetMetering];
    
    Novocaine *audioManager = [Novocaine audioManager];
    [audioManager setInputBlock:^(float *incomingAudio, UInt32 numFrames, UInt32 numChannels) {
        if (!self) { return; }
        
        ////
        /// reset metering
        if (shouldResetMetering) {
            [self preformResetMetering];
            return;
        }
        
        currentLevels.flatDB = [flatLevelMeter getdBLevel:incomingAudio numFrames:numFrames numChannels:numChannels];
        ////
        /// a weighted
        float aWeightedAudio[numFrames * numChannels];
        memcpy(aWeightedAudio, incomingAudio, numFrames * numChannels * sizeof(float));
        // apply a weigthed
        for (int i=0; i < 11; ++i) {
            [aPeakingEqs[i] filterData:aWeightedAudio numFrames:numFrames numChannels:numChannels];
        }
        currentLevels.aWeightedDB = [aWeightedLevelMeter getdBLevel:aWeightedAudio numFrames:numFrames numChannels:numChannels]+120.0f;

        ////
        /// c weighted
        float cWeightedAudio[numFrames * numChannels];
        memcpy(cWeightedAudio, incomingAudio, numFrames * numChannels * sizeof(float));
        // apply a weigthed
        for (int i=0; i < 11; ++i) {
            [cPeakingEqs[i] filterData:aWeightedAudio numFrames:numFrames numChannels:numChannels];
        }
        
        /// add a-weighted to the fft & octave analyser
        for (int i=0; i < numFrames; i+=numChannels) {
            fftAWeighted->process(cWeightedAudio[i]);
        }
        fftAWeighted->magsToDB();
        octAWeighted->calculate(fftAWeighted->magnitudesDB);
        for (int i =0; i < octAWeighted->nAverages; ++i) {
            nomalizedAWeighted[i].set(octAWeighted->peaks[i]);
        }
        
        currentLevels.cWeightedDB = [cWeightedLevelMeter getdBLevel:aWeightedAudio numFrames:numFrames numChannels:numChannels]+120.0f;
        
        /// peak
        if (currentLevels.flatDB < 999.0f) {
            if (peakLevels.flatDB < currentLevels.flatDB) {
                peakLevels.flatDB = peakLevels.flatDB + ((currentLevels.flatDB - peakLevels.flatDB) * 0.2);
            } else {
                peakLevels.flatDB = peakLevels.flatDB * 0.999f;
            }
        }
        /// peak a
        if (currentLevels.aWeightedDB < 999.0f) {
            if (peakLevels.aWeightedDB < currentLevels.aWeightedDB) {
                peakLevels.aWeightedDB = peakLevels.aWeightedDB + ((currentLevels.aWeightedDB - peakLevels.aWeightedDB) * 0.2);
            } else {
                peakLevels.aWeightedDB = peakLevels.aWeightedDB * 0.999f;
            }
        }
        /// peak b
        if (currentLevels.cWeightedDB < 999.0f) {
            if (peakLevels.cWeightedDB < currentLevels.cWeightedDB) {
                peakLevels.cWeightedDB = peakLevels.cWeightedDB + ((currentLevels.cWeightedDB - peakLevels.cWeightedDB) * 0.2);
            } else {
                peakLevels.cWeightedDB = peakLevels.cWeightedDB * 0.999f;
            }
        }
        
    }];
}

- (void)stop {
    NSLog(@"Sound Analyers Stop");
    Novocaine *audioManager = [Novocaine audioManager];
    [audioManager setInputBlock:nil];
}

#pragma mark - Recording

- (void)beginRecording {
    [self resetMetering];
}

- (COSMFeedModel *)stopRecording {
    COSMFeedModel *feedModel = [[COSMFeedModel alloc] init];
    
    NSLog(@"fft bins count %d", fftAWeighted->bins);
    
    float bin = 17.5;
    float peak = 0.0f;
    for (int i=0; i<octAWeighted->nAverages; ++i) {
        if (peak < octAWeighted->peaks[i]) {
            peak += octAWeighted->peaks[i];
        }
        if (i % averages == 0) {
            // work out the lower frequency of this bin
            bin = bin * 2.0f;
            COSMDatastreamModel *datastream = [[COSMDatastreamModel alloc] init];
            float binCenter = -1.0f;
            NSString *tag = @"ANSI:band=unknown";
            if (bin == 35.0f) {
                binCenter = 40.0f;
                tag = @"ANSI:band=16";
                
            } else if (bin == 70.0f) {
                binCenter = 80.0f;
                tag = @"ANSI:band=19";
                
            } else if (bin == 140.0f) {
                binCenter = 160.0f;
                tag = @"ANSI:band=22";
                
            } else if (bin == 280.0f) {
                binCenter = 315.0f;
                tag = @"ANSI:band=25";
                
            } else if (bin == 560.0f) {
                binCenter = 630.0f;
                tag = @"ANSI:band=28";
                
            } else if (bin == 1120.0f) {
                binCenter = 1250.0f;
                tag = @"ANSI:band=31";
                
            } else if (bin == 2240.0f) {
                binCenter = 2500.0f;
                tag = @"ANSI:band=34";
                
            } else if (bin == 4480.0f) {
                binCenter = 5000.0f;
                tag = @"ANSI:band=37";
                
            } else if (bin == 8960.0f) {
                binCenter = 10000.0f;
                tag = @"ANSI:band=40";
                
            } else if (bin == 17920.0f) {
                binCenter = 20000.0f;
                tag = @"ANSI:band=43";
            }
            [datastream.info setValue:[NSString stringWithFormat:@"%.0fhz", binCenter] forKeyPath:@"id"];
            [datastream.info setObject:[[NSMutableDictionary alloc] init] forKey:@"unit"];
            [datastream.info setValue:@"dB" forKeyPath:@"unit.label"];
            [datastream.info setValue:tag forKeyPath:@"tags"];
            [datastream.info setValue:[NSString stringWithFormat:@"%f", peak] forKeyPath:@"current_value"];
            NSLog(@"Bin %d: %f  hz pow: %f", i, bin, peak);
            peak = 0.0f;
            [feedModel.datastreamCollection.datastreams addObject:datastream];
        }
    }
    
    // Peak DB
    COSMDatastreamModel *peakDB = [[COSMDatastreamModel alloc] init];
    [peakDB.info setValue:@"Peak-dB" forKeyPath:@"id"];
    [peakDB.info setObject:[[NSMutableDictionary alloc] init] forKey:@"unit"];
    [peakDB.info setValue:@"dB" forKeyPath:@"unit.label"];
    [peakDB.info setValue:[NSString stringWithFormat:@"%f", peakLevels.flatDB] forKeyPath:@"current_value"];
    [feedModel.datastreamCollection.datastreams addObject:peakDB];
    
    // Peak DB
    COSMDatastreamModel *peakDBA = [[COSMDatastreamModel alloc] init];
    [peakDBA.info setValue:@"Peak-dBA" forKeyPath:@"id"];
    [peakDBA.info setObject:[[NSMutableDictionary alloc] init] forKey:@"unit"];
    [peakDBA.info setValue:@"dB" forKeyPath:@"unit.label"];
    [peakDBA.info setValue:[NSString stringWithFormat:@"%f", peakLevels.aWeightedDB] forKeyPath:@"current_value"];
    [feedModel.datastreamCollection.datastreams addObject:peakDBA];
    
    // Peak DB
    COSMDatastreamModel *peakDBC = [[COSMDatastreamModel alloc] init];
    [peakDBC.info setValue:@"Peak-dBC" forKeyPath:@"id"];
    [peakDBC.info setObject:[[NSMutableDictionary alloc] init] forKey:@"unit"];
    [peakDBC.info setValue:@"dB" forKeyPath:@"unit.label"];
    [peakDBC.info setValue:[NSString stringWithFormat:@"%f", peakLevels.cWeightedDB] forKeyPath:@"current_value"];
    [feedModel.datastreamCollection.datastreams addObject:peakDBC];
    
    NSLog(@"nAverages= %d, nAveragesPerOctave= %d, nSpectrum= %d, averageFrequencyIncrement= %f", octAWeighted->nAverages, octAWeighted->nAveragesPerOctave, octAWeighted->nSpectrum, octAWeighted->averageFrequencyIncrement);
    
    return feedModel;
}

#pragma mark - Rader Data Source

- (float)valueForSweeperParticle:(unsigned int)number inTotal:(unsigned int)numberOfParticles for:(RadarViewController *)radarViewController {
    BOOL useOct = YES;
    if (useOct) {
        // NSLog(@"%u", oct->nAverages);
        float index = RadarMapFloat(number, 0.0f, numberOfParticles, 0.0f, octAWeighted->nAverages - 20);
        unsigned int peakDbIndex = floor(index);
        return RadarMapFloat(nomalizedAWeighted[peakDbIndex].getNormalized(), 0.0f, 0.6f, 0.2f, 1.0f);
    } else {
        //float index = RadarMapFloat(number, 0.0f, numberOfParticles, 0.0f, 1024/2);
        //unsigned int peakDbIndex = floor(index);
        //return RadarMapFloat(nomalized[peakDbIndex].getNormalized(), 0.0f, 0.6f, 0.2f, 1.0f);
    }
    return 0;
}

#pragma mark - Life Cycle

- (void)dealloc {
    NSLog(@"Sound Analyser dealloc");
    delete fftAWeighted;
    delete octAWeighted;
    delete nomalizedAWeighted;
}

void MakeWeighted(NVPeakingEQFilter *aPeakingEq, NVPeakingEQFilter *cPeakingEq, int freq) {
    DBWeighting weighting = CalculateDBWeighting(freq);
    aPeakingEq.G = weighting.a;
    aPeakingEq.centerFrequency = freq;
    aPeakingEq.Q = 0.2f;
    cPeakingEq.G = weighting.c;
    cPeakingEq.centerFrequency = freq;
    cPeakingEq.Q = 0.2f;
}

- (id)init {
    self=[super init];
    if (self) {
        NSLog(@"Sound Analyser Init");
        self.flatLevelMeter = [[NVSoundLevelMeter alloc] init];
        self.aWeightedLevelMeter = [[NVSoundLevelMeter alloc] init];
        self.cWeightedLevelMeter = [[NVSoundLevelMeter alloc] init];
        
//        fftAWeighted = new maxiFFT();
//        octAWeighted = new maxiFFTOctaveAnalyzer();
//        NSInteger fftSize = 1024;
//        NSInteger windowSize = 1024; //1024;
//        fftAWeighted->setup(fftSize, windowSize, 256);
//        NSInteger averages = 12; // setting this to 12 should be each step in the octave
//        octAWeighted->setup([Novocaine audioManager].samplingRate, fftSize/2, averages);
//        
//        nomalizedAWeighted = new Normalizing<float>[octAWeighted->nAverages];
        
        averages = 3; // setting this to 12 should be each step in the octave
        
        for (int i=0; i<11; ++i) {
            aPeakingEqs[i] = [[NVPeakingEQFilter alloc] initWithSamplingRate:[Novocaine audioManager].samplingRate];
            cPeakingEqs[i] = [[NVPeakingEQFilter alloc] initWithSamplingRate:[Novocaine audioManager].samplingRate];
        }
        
        // eq frequencies
        MakeWeighted(aPeakingEqs[0], cPeakingEqs[0], 10);
        MakeWeighted(aPeakingEqs[1], cPeakingEqs[1], 20);
        MakeWeighted(aPeakingEqs[2], cPeakingEqs[2], 40);
        MakeWeighted(aPeakingEqs[3], cPeakingEqs[3], 100);
        MakeWeighted(aPeakingEqs[4], cPeakingEqs[4], 200);
        MakeWeighted(aPeakingEqs[5], cPeakingEqs[5], 400);
        MakeWeighted(aPeakingEqs[6], cPeakingEqs[6], 1000);
        MakeWeighted(aPeakingEqs[7], cPeakingEqs[7], 2000);
        MakeWeighted(aPeakingEqs[8], cPeakingEqs[8], 4000);
        MakeWeighted(aPeakingEqs[9], cPeakingEqs[9], 10000);
        MakeWeighted(aPeakingEqs[10], cPeakingEqs[10], 20000);
        
        shouldResetMetering = YES;
    }
    
    return self;
}

@end
