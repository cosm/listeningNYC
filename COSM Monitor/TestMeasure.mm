#import "TestMeasure.h"
#import "DDLog.h"
#import "DBTool.h"
#import "maxiFFT.h"


static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface TestMeasure () {
    maxiFFT *fft;
    maxiFFTOctaveAnalyzer *oct;
}

@end

@implementation TestMeasure

#pragma mark - Tools

@synthesize flatLevelMeter, aWeightedLevelMeter, cWeightedLevelMeter;

#pragma mark - Measure

@synthesize currentLevels;

-(DBCollection)peakLevels {
    return peakLevels;
}

- (void)start {
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
        
        /// add a-weighted to the fft & octave analyser
        for (int i=0; i < numFrames; i+=numChannels) {
            fft->process(aWeightedAudio[i]);
        }
        fft->magsToDB();
        oct->calculate(fft->magnitudesDB);
        
        ////
        /// c weighted
        float cWeightedAudio[numFrames * numChannels];
        memcpy(cWeightedAudio, incomingAudio, numFrames * numChannels * sizeof(float));
        // apply a weigthed
        for (int i=0; i < 11; ++i) {
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
    
}

#pragma mark - Life Cycle

void MakeWeighted(NVPeakingEQFilter *aPeakingEq, NVPeakingEQFilter *cPeakingEq, int freq) {
    DBWeighting weighting = CalculateDBWeighting(freq);
    aPeakingEq.G = weighting.a;
    aPeakingEq.centerFrequency = freq;
    aPeakingEq.Q = 0.2f;
    cPeakingEq.G = weighting.c;
    cPeakingEq.centerFrequency = freq;
    cPeakingEq.Q = 0.2f;
}

- (void)dealloc {
    delete fft;
    delete oct;
}

- (id)init {
    if ((self=[super init])) {
        self.flatLevelMeter = [[NVSoundLevelMeter alloc] init];
        self.aWeightedLevelMeter = [[NVSoundLevelMeter alloc] init];
        self.cWeightedLevelMeter = [[NVSoundLevelMeter alloc] init];
        
        fft = new maxiFFT();
        oct = new maxiFFTOctaveAnalyzer();
        NSInteger fftSize = 1024;
        NSInteger windowSize = 1024; //1024;
        fft->setup(fftSize, windowSize, 256);
        NSInteger averages = 0; // setting this to 12 should be each step in the octave
        oct->setup([Novocaine audioManager].samplingRate, fftSize/2, averages);
        
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
