#import <UIKit/UIKit.h>
#import "TagDeleteView.h"
#import "MapWebViewController.h"
#import "COSM.h"
#import "CircleBands.h"
#import "SubmittingViewController.h"

@interface PostCaptureViewController : UIViewController<TagDeleteViewDelegate, MapWebViewControllerDelegate, COSMModelDelegate, CircleBandsDatasource, SubmittingViewControllerDelegate>

// Data
@property (nonatomic, strong) NSMutableArray *tags;
@property double elevation;

// COSM Model
@property (nonatomic, strong) COSMFeedModel *cosmFeed;
- (void)modelDidSave:(COSMModel *)model;
- (void)modelFailedToSave:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

// IB
@property (nonatomic, weak) IBOutlet CircleBands *circleBands;
@property (nonatomic, weak) IBOutlet UIView *tagsContainer;
@property (nonatomic, weak) IBOutlet UISlider *slider;
- (IBAction)deleteTagsTouched:(id)sender;
- (IBAction)submit:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)locate:(id)sender;
// UI
@property (nonatomic, weak) NSMutableArray *tagViews;
@property (nonatomic, strong) NSMutableArray *deleteButtons;
- (void)layoutTags;
@property (nonatomic, strong) MapWebViewController *mapWebViewController;
@property (nonatomic, strong) SubmittingViewController *submittingViewController;

// Tag Delete Delegate
- (void)tagDeleteView:(TagDeleteView *)sender requestsDeletionOf:(NSString *)tag;

@end
