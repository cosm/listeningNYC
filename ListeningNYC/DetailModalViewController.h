#import <UIKit/UIKit.h>
#import "MapWebViewController.h"
@class CircleBands;
@class COSMFeedModel;

@interface DetailModalViewController : UIViewController<MapWebViewControllerDelegate>

// Data
@property (nonatomic, strong) COSMFeedModel *feed;

// IB
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet CircleBands *circleBands;
@property (nonatomic, weak) IBOutlet UIView *tagsContainer;
@property (nonatomic, weak) IBOutlet UISlider *likeDislikeSlider;
@property (nonatomic, weak) IBOutlet UIView *mapContainer;
@property (nonatomic, weak) IBOutlet UIImageView *modalBackgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *dbLabel;
- (IBAction)close:(id)sender;

// Map
@property (nonatomic, strong) MapWebViewController *mapWebViewController;
- (void)mapDidLoad;

@end
