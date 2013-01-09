#import <UIKit/UIKit.h>
#import "MapWebViewController.h"
@class MapWebViewController;

@interface MapViewController : UIViewController<MapWebViewControllerDelegate>

// IB
@property (nonatomic, weak) IBOutlet UIView *webContainerView;
- (IBAction)toggleMapOptionsPressed:(id)sender;
- (IBAction)locatePressed:(id)sender;

// Map Web View & Delegate
@property (nonatomic, strong) MapWebViewController *mapWebViewController;
- (void)mapDidLoad;

@end
