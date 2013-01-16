#import <UIKit/UIKit.h>
#import "CountdownViewController.h"
#import "RecordingViewController.h"
@class SoundAnalyser;
@class RadarViewController;

@interface CaptureViewController : UIViewController<CountdownViewControllerDelegate, RecordingViewControllerDelegate>

// IB
@property (nonatomic, weak) IBOutlet UIView *radarContainerView;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
- (IBAction)startButtonPressed:(id)sender;

// Recording
@property (nonatomic, weak) IBOutlet UIView *recordingContainerView;
@property (nonatomic, strong) RecordingViewController *recordingViewController;
- (void)recordingViewControllerDidCancel;
- (void)recordingViewControllerDidFinish;
- (void)recordingViewControllerDidRequestNext;

// Countdown
@property (nonatomic, weak) IBOutlet UIView *countdownHolder;
@property (nonatomic, strong) CountdownViewController *countdownViewController;
- (void)countdownViewControllerDidCountdown;

// radar view controller
@property (nonatomic, strong) SoundAnalyser *soundAnalyser;
@property (nonatomic, strong) RadarViewController *radarViewController;

@end
