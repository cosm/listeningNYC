#import <UIKit/UIKit.h>
#import "COSM.h"
#import "MapKit/MapKit.h"
@class LoadingViewController;

@interface MeasureDetailViewController : UIViewController<UITextFieldDelegate, COSMModelDelegate>

// options
@property (nonatomic, retain) COSMFeedModel *feed;
@property float dBA;
@property float dBC;

// IB
- (IBAction)save:(id)sender;
@property (nonatomic, weak) IBOutlet UITextField *measureAt;
@property (nonatomic, weak) IBOutlet UITextField *soundIs;
@property (nonatomic, weak) IBOutlet UISlider *likeDislike;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

// UI
@property (nonatomic, strong) LoadingViewController *loadingViewController;

// Feed deleagte
- (void)modelDidSave:(COSMModel *)model;
- (void)modelFailedToSave:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

@end
