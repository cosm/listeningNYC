#import <UIKit/UIKit.h>
@class RadarViewController;
@class TestMeasure;

@interface RadarTestViewController : UIViewController

// radar view controller
@property (nonatomic, strong) TestMeasure *testMeasure;
@property (nonatomic, weak) RadarViewController *radarViewController;


@end
