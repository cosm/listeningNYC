#import <Foundation/Foundation.h>
#import "Novocaine.h"
#import "NVSoundLevelMeter.h"
#import "DBTool.h"
#import "NVPeakingEQFilter.h"
#import "RadarViewController.h"
@class COSMFeedModel;

@interface SoundAnalyser : NSObject<RadarViewControllerDatasource> {
    NVPeakingEQFilter *aPeakingEqs[11];
    NVPeakingEQFilter *cPeakingEqs[11];
    DBCollection peakLevels;
}

// tools
@property (nonatomic, strong) NVSoundLevelMeter *flatLevelMeter;
@property (nonatomic, strong) NVSoundLevelMeter *aWeightedLevelMeter;
@property (nonatomic, strong) NVSoundLevelMeter *cWeightedLevelMeter;

// measure
- (void)start;
- (void)stop;
@property DBCollection currentLevels;
-(DBCollection)peakLevels;

// recording
- (void)beginRecording;
- (COSMFeedModel *)stopRecording;

// radar datasource
- (float)valueForSweeperParticle:(unsigned int)number inTotal:(unsigned int)numberOfParticles for:(RadarViewController *)radarViewController;

@end
