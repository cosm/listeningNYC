#import <UIKit/UIKit.h>
#import "MapWebViewController.h"
#import "CircleBands.h"
#import "COSMFeedModel.h"
#import "OHAttributedLabel.h"

@interface DetailModalViewController : UIViewController<MapWebViewControllerDelegate, CircleBandsDatasource, COSMModelDelegate>

// Data
@property (nonatomic, strong) COSMFeedModel *feed;
// or
- (void)fetchFeedWithId:(NSInteger)feedId;

// IB
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet CircleBands *circleBands;
@property (nonatomic, weak) IBOutlet UIView *tagsContainer;
@property (nonatomic, weak) IBOutlet UISlider *likeDislikeSlider;
@property (nonatomic, weak) IBOutlet UIView *mapContainer;
@property (nonatomic, weak) IBOutlet UIImageView *modalBackgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *dbLabel;
@property (nonatomic, weak) IBOutlet OHAttributedLabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIButton *descriptionBackgroundButton;
- (IBAction)close:(id)sender;
- (IBAction)descriptionBackgroundButtonPressed:(id)sender;
- (IBAction)descriptionButtonPressed:(id)sender;

// Map
@property (nonatomic, strong) MapWebViewController *mapWebViewController;
- (void)mapDidLoad;

@end
