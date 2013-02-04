#import <UIKit/UIKit.h>
#import "CountdownViewController.h"
#import "RecordingViewController.h"
@class SoundAnalyser;
@class RadarViewController;
@class COSMFeedModel;

@interface CaptureViewController : UIViewController<CountdownViewControllerDelegate, RecordingViewControllerDelegate>

// IB
@property (nonatomic, weak) IBOutlet UIView *radarContainerView;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
- (IBAction)startButtonPressed:(id)sender;
// debug
@property BOOL isDebugMode;
@property (nonatomic, weak) IBOutlet UIView *debugContainerView;
@property (nonatomic, weak) IBOutlet UILabel *delayForLabel;
@property (nonatomic, weak) IBOutlet UILabel *decayLabel;
@property (nonatomic, weak) IBOutlet UISlider *delaySlider;
@property (nonatomic, weak) IBOutlet UISlider *decaySlider;
@property (nonatomic, weak) IBOutlet UILabel *dbLabel;
- (IBAction)delayForChanged:(UISlider *)slider;
- (IBAction)decayForChanged:(UISlider *)slider;

// Recording
@property (nonatomic, weak) IBOutlet UIView *recordingContainerView;
@property (nonatomic, strong) RecordingViewController *recordingViewController;
- (void)recordingViewControllerDidCancel;
- (void)recordingViewControllerDidFinish;
- (void)recordingViewControllerDidRequestNext;
@property (nonatomic, strong) COSMFeedModel *cosmFeed;

// Countdown
@property (nonatomic, weak) IBOutlet UIView *countdownHolder;
@property (nonatomic, strong) CountdownViewController *countdownViewController;
- (void)countdownViewControllerDidCountdown;

// radar view controller
@property (nonatomic, strong) SoundAnalyser *soundAnalyser;
@property (nonatomic, strong) RadarViewController *radarViewController;

// Timer
@property (nonatomic, strong) NSTimer *dbLabelUpdateTimer;
@property BOOL shouldUpdateDbLabel;
- (void)dbLabelUpdateTimerDidFire;

@end
