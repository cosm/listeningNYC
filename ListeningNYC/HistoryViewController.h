#import <UIKit/UIKit.h>
#import "RecordingCell.h"

@class DetailModalViewController;

@interface HistoryViewController : UITableViewController<RecordingCellDelegate>

// Data
@property (nonatomic, strong) NSMutableArray *feeds;

// UI
@property (nonatomic, strong) DetailModalViewController *detailModalViewController;

// Cell Delegate
- (void)cellWantsDeletion:(RecordingCell*)cell;

@end
