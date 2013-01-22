#import <UIKit/UIKit.h>

@class DetailModalViewController;

@interface HistoryViewController : UITableViewController

// Data
@property (nonatomic, strong) NSArray *feeds;

// UI
@property (nonatomic, strong) DetailModalViewController *detailModalViewController;

@end
