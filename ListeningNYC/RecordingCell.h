#import <UIKit/UIKit.h>
@class COSMFeedModel;

@class RecordingCell;
@protocol RecordingCellDelegate<NSObject>
@optional
- (void)cellWantsDeletion:(RecordingCell*)cell;
@end

@interface RecordingCell : UITableViewCell<UIAlertViewDelegate>

// data
@property (nonatomic, weak) id<RecordingCellDelegate> delegate;
@property (nonatomic, strong) COSMFeedModel *feed;

// IB
@property (nonatomic, weak) IBOutlet UIView *tagContainer;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
- (IBAction)deleteRecording:(id)sender;

// UI
/// call this when the data has been set
@property (nonatomic, strong) NSArray *tagViews;
- (void)swipedLeft:(id)sender;
- (void)swipedRight:(id)sender;

@end
