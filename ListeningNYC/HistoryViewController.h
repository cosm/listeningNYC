#import <UIKit/UIKit.h>
#import "RecordingCell.h"

@class DetailModalViewController;

@interface HistoryViewController : UITableViewController<RecordingCellDelegate>

// Data
@property (nonatomic, strong) NSMutableArray *feeds;
@property (nonatomic, strong) NSMutableArray *unsyncedFeeds;

// UI
@property (nonatomic, strong) DetailModalViewController *detailModalViewController;
@property (nonatomic, strong) UIImageView *startHereImageView;

// Cell Delegate
- (void)cellWantsDeletion:(RecordingCell*)cell;

@end
