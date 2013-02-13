#import "SoundAnalyser.h"
#import "DBTool.h"
#import "maxiFFT.h"
#import "RadarSweeper.h"
#import "COSM.h"
#import "Utils.h"

template<typename T>
struct Normalizing {
    Normalizing() {
        min = std::numeric_limits<T>::max();
        max = std::numeric_limits<T>::min();
        total = 0.0f;
        count = 0;
    }
    T max;
    T min;
    T currentValue;
    T total;
    unsigned int count;
    
    void set(T value) {
        if (value < min) { min = value; }
        if (value > max) { max = value; }
        currentValue = value;
        total += value;
        ++count;
    }
    
    float getNormalized () {
        float n = map(currentValue, min, max, 0.0f, 1.0f);
        return n;
    }
    
    float getAverage() {
        return total / float(count);
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
    maxiFFT *fft;
    maxiFFTOctaveAnalyzer *oct;
    Normalizing<float> *nomalized;
    BOOL shouldResetMetering;
    NSInteger averages;
    BOOL hasAddedNormailzed;
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
    self.peakDb = -99999.9f;
    self.currentDb = -99999.9f;
    
    if (fft) {
        delete fft;
        delete oct;
        delete nomalized;
    }
    
    fft = new maxiFFT();
    oct = new maxiFFTOctaveAnalyzer();
    // oct->peakDecayRate = 1.0;
    NSInteger fftSize = 1024 * 2;
    NSInteger windowSize = 1024; //1024;
    Float64 samplingRate = [Novocaine audioManager].samplingRate;
    fft->setup(fftSize, windowSize, 256);
    oct->setup(samplingRate, fftSize/2, averages);
    nomalized = new Normalizing<float>[oct->nAverages];
    hasAddedNormailzed = NO;
    shouldResetMetering = NO;

}

- (void)start {
    NSLog(@"Sound Analyers Start");
    
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
        if (self.peakDb < currentLevels.flatDB) { self.peakDb = currentLevels.flatDB; }
        self.currentDb = currentLevels.flatDB;
        
        ////
        /// a weighted
        float aWeightedAudio[numFrames * numChannels];
        memcpy(aWeightedAudio, incomingAudio, numFrames * numChannels * sizeof(float));
        // apply a weigthed
        for (int i=0; i < 11; ++i) {
            [aPeakingEqs[i] filterData:aWeightedAudio numFrames:numFrames numChannels:numChannels];
        }
        currentLevels.aWeightedDB = [aWeightedLevelMeter getdBLevel:aWeightedAudio numFrames:numFrames numChannels:numChannels]+120.0f;
        
    
        /// add fft & octave analyser
        for (int i=0; i < numFrames; i+=numChannels) {
            // bug here
            fft->process(incomingAudio[i]);
        }
        fft->magsToDB();
        oct->calculate(fft->magnitudesDB);
        for (int i =0; i < oct->nAverages; ++i) {
            if (kRADAR_USE_PEAKS) {
                nomalized[i].set(oct->peaks[i]);
            } else {
                nomalized[i].set(oct->averages[i]);
            }
        }

        ////
        /// c weighted
        float cWeightedAudio[numFrames * numChannels];
        memcpy(cWeightedAudio, incomingAudio, numFrames * numChannels * sizeof(float));
        // apply a weigthed
        for (int i=0; i < 11; ++i) {
            // Bug error throw here
            [cPeakingEqs[i] filterData:aWeightedAudio numFrames:numFrames numChannels:numChannels];
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
        /// peak c
        if (currentLevels.cWeightedDB < 999.0f) {
            if (peakLevels.cWeightedDB < currentLevels.cWeightedDB) {
                peakLevels.cWeightedDB = peakLevels.cWeightedDB + ((currentLevels.cWeightedDB - peakLevels.cWeightedDB) * 0.2);
            } else {
                peakLevels.cWeightedDB = peakLevels.cWeightedDB * 0.999f;
            }
        }
        
        hasAddedNormailzed = YES;
        
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
    NSLog(@"number of averages %d", oct->nAverages);
}

- (COSMFeedModel *)stopRecording {
    COSMFeedModel *feedModel = [[COSMFeedModel alloc] init];
    
    NSLog(@"fft bins count %d", fft->bins);
    
    float bin = 17.5;
    float peak = -60.0f;
    for (int i=0; i<oct->nAverages; ++i) {
        // find the highest peak since reset
        if (peak < nomalized[i].getAverage()) {
            peak = nomalized[i].getAverage();
        }
        NSLog(@"bin %d, %.03f", i, nomalized[i].getAverage());
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
            NSLog(@"BIN created %0.0fhz %@ = %0.5f ", binCenter, tag, peak);
            [datastream.info setValue:[NSString stringWithFormat:@"%.0fhz", binCenter] forKeyPath:@"id"];
            [datastream.info setObject:[[NSMutableDictionary alloc] init] forKey:@"unit"];
            [datastream.info setValue:@"dB" forKeyPath:@"unit.label"];
            [datastream.info setValue:tag forKeyPath:@"tags"];
            [datastream.info setValue:[NSString stringWithFormat:@"%f", peak] forKeyPath:@"current_value"];
            peak = -60.0f;
            [feedModel.datastreamCollection.datastreams addObject:datastream];
        }
    }
    
    // Peak DB
    COSMDatastreamModel *peakDB = [[COSMDatastreamModel alloc] init];
    [peakDB.info setValue:@"Peak-dB" forKeyPath:@"id"];
    [peakDB.info setObject:[[NSMutableDictionary alloc] init] forKey:@"unit"];
    [peakDB.info setValue:@"dB" forKeyPath:@"unit.label"];
    [peakDB.info setValue:[NSString stringWithFormat:@"%f", peakLevels.flatDB + 60.0f] forKeyPath:@"current_value"];
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
    
    //NSLog(@"nAverages= %d, nAveragesPerOctave= %d, nSpectrum= %d, averageFrequencyIncrement= %f", octAWeighted->nAverages, octAWeighted->nAveragesPerOctave, octAWeighted->nSpectrum, octAWeighted->averageFrequencyIncrement);
    
    return feedModel;
}

#pragma mark - Rader Data Source

- (float)valueForSweeperParticle:(unsigned int)number inTotal:(unsigned int)numberOfParticles for:(RadarViewController *)radarViewController wantsAll:(BOOL)isAll {
    int startPoint = -4;
    int index = RadarMapFloat(number, 0.0f, numberOfParticles, startPoint, oct->nAverages);
    
    if (index < 0) return 0.0f;
    
    if (!hasAddedNormailzed) return 0.0f;
 
    if (isAll) {
        return [Utils mapDbToAlpha:nomalized[index].getAverage()];
    } else {
        return [Utils mapDbToAlpha:nomalized[index].currentValue];
    }
}

#pragma mark - DB Levels

@synthesize currentDb;
@synthesize peakDb;

#pragma mark - Life Cycle

- (void)dealloc {
    NSLog(@"Sound Analyser dealloc");
    delete fft;
    delete oct;
    delete nomalized;
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
        averages = 2; // setting this to 12 should be each step in the octave
        
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
