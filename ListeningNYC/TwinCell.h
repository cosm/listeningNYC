#import <UIKit/UIKit.h>

@interface TwinCell : UITableViewCell

// data
@property (nonatomic, strong) NSArray *tagStrings_left;
@property (nonatomic, strong) NSArray *tagStrings_right;

// IB
@property (nonatomic, weak) IBOutlet UIView *tagContainer_left;
@property (nonatomic, weak) IBOutlet UIView *tagContainer_right;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel_left;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel_right;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel_left;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel_right;

// UI
/// call this when the data has been set
@property (nonatomic, strong) NSArray *tagViews_left;
@property (nonatomic, strong) NSArray *tagViews_right;

@end
