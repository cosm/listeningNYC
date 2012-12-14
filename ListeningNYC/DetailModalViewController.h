#import <UIKit/UIKit.h>

@class CircleBands;

@interface DetailModalViewController : UIViewController

// IB
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIWebView *webview;
@property (nonatomic, weak) IBOutlet CircleBands *circleBands;
- (IBAction)close:(id)sender;

@end
