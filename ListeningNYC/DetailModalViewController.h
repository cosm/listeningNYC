#import <UIKit/UIKit.h>

@class CircleBands;

@interface DetailModalViewController : UIViewController

// IB
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIWebView *webview;
@property (nonatomic, weak) IBOutlet CircleBands *circleBands;
@property (nonatomic, weak) IBOutlet UIView *tagsContainer;
@property (nonatomic, weak) IBOutlet UISlider *likeDislikeSlider;
- (IBAction)close:(id)sender;

@end
