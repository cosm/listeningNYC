#import <UIKit/UIKit.h>
@class SoundAnalyser;
@class RadarViewController;

@interface CaptureViewController : UIViewController

// IB
@property (nonatomic, weak) IBOutlet UIView *radarContainerView;

// radar view controller
@property (nonatomic, strong) SoundAnalyser *soundAnalyser;
@property (nonatomic, strong) RadarViewController *radarViewController;

@end
