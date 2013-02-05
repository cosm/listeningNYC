#import <UIKit/UIKit.h>

@class SubmittingViewController;
@protocol SubmittingViewControllerDelegate <NSObject>
@optional
- (void)submittingSoundViewControllerDidComplete:(SubmittingViewController*)submittingViewController;
@end

@interface SubmittingViewController : UIViewController

// delegate
@property (nonatomic, weak) id<SubmittingViewControllerDelegate> delegate;

// IB
@property (nonatomic, weak) IBOutlet UIView *successContainerView;
@property (nonatomic, weak) IBOutlet UIView *submittingContainerView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
- (IBAction)okPressed:(id)sender;

// control
- (void)showSubmitting;
- (void)showSuccess;

@end
