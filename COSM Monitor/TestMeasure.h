#import <Foundation/Foundation.h>
#import "Novocaine.h"
#import "NVSoundLevelMeter.h"
#import "DBTool.h"
#import "NVPeakingEQFilter.h"

@interface TestMeasure : NSObject {
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

@end
