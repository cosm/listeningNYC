#import <UIKit/UIKit.h>
@class MapWebViewController;

@interface MapViewController : UIViewController

// IB
@property (nonatomic, weak) IBOutlet UIView *webContainerView;
- (IBAction)toggleMapOptionsPressed:(id)sender;

// Webview
@property (nonatomic, strong) MapWebViewController *mapWebViewController;

@end
