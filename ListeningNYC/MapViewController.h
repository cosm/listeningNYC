#import <UIKit/UIKit.h>
#import "MapWebViewController.h"
@class MapWebViewController;
@class DetailModalViewController;

@interface MapViewController : UIViewController<MapWebViewControllerDelegate>

@property (nonatomic, strong) DetailModalViewController *detailModalViewController;

// IB
@property (nonatomic, weak) IBOutlet UIView *webContainerView;
- (IBAction)toggleMapOptionsPressed:(id)sender;
- (IBAction)locatePressed:(id)sender;
- (IBAction)filterChanged:(id)sender;

// Map Web View & Delegate
@property (nonatomic, strong) MapWebViewController *mapWebViewController;
- (void)mapDidLoad;

@end
