#import <UIKit/UIKit.h>

@protocol CountdownViewControllerDelegate <NSObject>
@optional
- (void)countdownViewControllerDidCountdown;
- (void)countdownViewControllerWillCountdown;
@end

@interface CountdownViewController : UIViewController

// Counter
@property (nonatomic, strong) NSTimer *timer;
- (void)timerDidUpdate;
@property NSInteger state;
@property (nonatomic, weak) id<CountdownViewControllerDelegate> delegate;

// IB
@property (nonatomic, weak) IBOutlet UIButton *okButton;
- (IBAction)okPressed:(id)sender;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;


@end
    