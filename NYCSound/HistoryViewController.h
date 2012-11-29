#import <UIKit/UIKit.h>
#import "COSM.h"

@interface HistoryViewController : UITableViewController<COSMFeedCollectionDelegate>

// data
@property (nonatomic, strong) COSMFeedCollection *feedCollection;

// collection delegates
- (void)feedCollectionDidFetch:(COSMFeedCollection *)feedCollection;
- (void)feedCollectionFailedToFetch:(COSMFeedCollection *)feedCollection withError:(NSError*)error json:(id)JSON;

@end
