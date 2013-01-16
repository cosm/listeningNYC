#import <UIKit/UIKit.h>

@protocol RecordingViewControllerDelegate <NSObject>
@optional
- (void)recordingViewControllerDidCancel;
- (void)recordingViewControllerDidFinish;
- (void)recordingViewControllerDidRequestNext;
@end

@interface RecordingViewController : UIViewController

// Timing
@property (nonatomic, weak) id<RecordingViewControllerDelegate> delegate;
@property (nonatomic, strong) NSTimer *timer;

// IB
@property (nonatomic, weak) IBOutlet UIImageView *progressImageView;
@property (nonatomic, weak) IBOutlet UIImageView *textImageView;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
- (IBAction)cancelRecordingPressed:(id)sender;
- (IBAction)nextPressed:(id)sender;

@end
