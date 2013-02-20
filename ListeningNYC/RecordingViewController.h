#import <UIKit/UIKit.h>
@class COSMFeedModel;
@class OHAttributedLabel;

@protocol RecordingViewControllerDelegate <NSObject>
@optional
- (void)recordingViewControllerDidCancel;
- (void)recordingViewControllerDidFinish;
- (void)recordingViewControllerDidRequestNext;
@end

@interface RecordingViewController : UIViewController

// data
- (void)setDescriptionUsingFeed:(COSMFeedModel*)feed;

// Timing
@property (nonatomic, weak) id<RecordingViewControllerDelegate> delegate;
@property (nonatomic, strong) NSTimer *timer;

// IB
@property (nonatomic, weak) IBOutlet UIImageView *progressImageView;
@property (nonatomic, weak) IBOutlet UIImageView *textImageView;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIImageView *audioDescriptionImageView;
@property (nonatomic, weak) IBOutlet OHAttributedLabel *descriptionLabel;
- (IBAction)cancelRecordingPressed:(id)sender;
- (IBAction)nextPressed:(id)sender;

@end
