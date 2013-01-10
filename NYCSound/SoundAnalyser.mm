#import "SoundAnalyser.h"
#import "DBTool.h"
#import "maxiFFT.h"
#import "RadarSweeper.h"

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
    maxiFFT *fft;
    maxiFFTOctaveAnalyzer *oct;
    Normalizing<float> *nomalized;
}

@end

@implementation SoundAnalyser

#pragma mark - Tools

@synthesize flatLevelMeter, aWeightedLevelMeter, cWeightedLevelMeter;

#pragma mark - Measure

@synthesize currentLevels;

-(DBCollection)peakLevels {
    return peakLevels;
}

- (void)start {
    NSLog(@"Sound Analyers start");
    
    peakLevels.flatDB = -99999.9f;
    peakLevels.aWeightedDB = -99999.9f;
    peakLevels.cWeightedDB = -99999.9f;
    
    Novocaine *audioManager = [Novocaine audioManager];
    [audioManager setInputBlock:^(float *incomingAudio, UInt32 numFrames, UInt32 numChannels) {
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
            fft->process(cWeightedAudio[i]);
        }
        fft->magsToDB();
        oct->calculate(fft->magnitudesDB);
        for (int i =0; i < oct->nAverages; ++i) {
            nomalized[i].set(oct->peaks[i]);
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

#pragma mark - Rader Data Source

- (float)valueForSweeperParticle:(unsigned int)number inTotal:(unsigned int)numberOfParticles for:(RadarViewController *)radarViewController {
    BOOL useOct = YES;
    if (useOct) {
        // NSLog(@"%u", oct->nAverages);
        float index = RadarMapFloat(number, 0.0f, numberOfParticles, 0.0f, oct->nAverages - 20);
        unsigned int peakDbIndex = floor(index);
        return RadarMapFloat(nomalized[peakDbIndex].getNormalized(), 0.0f, 0.6f, 0.2f, 1.0f);
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
        
        fft = new maxiFFT();
        oct = new maxiFFTOctaveAnalyzer();
        NSInteger fftSize = 1024;
        NSInteger windowSize = 1024; //1024;
        fft->setup(fftSize, windowSize, 256);
        NSInteger averages = 12; // setting this to 12 should be each step in the octave
        oct->setup([Novocaine audioManager].samplingRate, fftSize/2, averages);
        
        nomalized = new Normalizing<float>[oct->nAverages];
        
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
    }
    return self;
}

@end
