#import <UIKit/UIKit.h>
#import "MapWebViewController.h"

@class CircleBands;

@interface DetailModalViewController : UIViewController<MapWebViewControllerDelegate>

// IB
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet CircleBands *circleBands;
@property (nonatomic, weak) IBOutlet UIView *tagsContainer;
@property (nonatomic, weak) IBOutlet UISlider *likeDislikeSlider;
@property (nonatomic, weak) IBOutlet UIView *mapContainer;
@property (nonatomic, weak) IBOutlet UIImageView *modalBackgroundImageView;
- (IBAction)close:(id)sender;

// Map
@property (nonatomic, strong) MapWebViewController *mapWebViewController;
- (void)mapDidLoad;

@end
