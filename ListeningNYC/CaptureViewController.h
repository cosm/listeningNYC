#import <UIKit/UIKit.h>
@class TestMeasure;
@class RadarViewController;

@interface CaptureViewController : UIViewController

// radar view controller
@property (nonatomic, strong) TestMeasure *testMeasure;
@property (nonatomic, weak) RadarViewController *radarViewController;

@end
