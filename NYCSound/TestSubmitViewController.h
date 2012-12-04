#import <UIKit/UIKit.h>
#import "LoadingViewController.h"
#import "DBTool.h"
#import "COSM.h"

@interface TestSubmitViewController : UIViewController<COSMModelDelegate>

// data
@property (nonatomic, retain) COSMFeedModel *feed;
@property DBCollection db;

// IB
@property (nonatomic, weak) IBOutlet UISlider *slider;
- (IBAction)saveToCOSM:(id)sender;

// UI
@property (nonatomic, strong) LoadingViewController *loadingViewController;

// Feed deleagte
- (void)modelDidSave:(COSMModel *)model;
- (void)modelFailedToSave:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

@end
