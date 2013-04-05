#import <UIKit/UIKit.h>
#import "RecordingCell.h"
#import "COSMModelDelegate.h"

@class DetailModalViewController;
@class DeleteingViewController;

@interface HistoryViewController : UITableViewController<RecordingCellDelegate, COSMModelDelegate>

// Data
@property (nonatomic, strong) NSMutableArray *feeds;
@property (nonatomic, strong) NSMutableArray *unsyncedFeeds;

// UI
@property (nonatomic, strong) DetailModalViewController *detailModalViewController;
@property (nonatomic, strong) UIImageView *startHereImageView;
@property (nonatomic, strong) DeleteingViewController* deletingViewController;

// Cell Delegate
- (void)cellWantsDeletion:(RecordingCell*)cell;

@end
