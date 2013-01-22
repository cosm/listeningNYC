#import "RecordingViewController.h"

@interface RecordingViewController ()

@end

@implementation RecordingViewController

#pragma mark - Timing

@synthesize delegate, timer;

- (void)timerDidUpdate {
    [self.timer invalidate];
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingViewControllerDidFinish)]) {
        [self.delegate recordingViewControllerDidFinish];
    }
    self.nextButton.hidden = NO;
}

#pragma mark - IB

@synthesize progressImageView, textImageView, nextButton;

- (IBAction)cancelRecordingPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingViewControllerDidCancel)]) {
        [self.delegate recordingViewControllerDidCancel];
    }
}

- (IBAction)nextPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingViewControllerDidRequestNext)]) {
        [self.delegate recordingViewControllerDidRequestNext];
    }
}

#pragma mark - Animate Recording Text

- (void)startAnimation {
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         self.textImageView.alpha = (self.textImageView.alpha > 0.5) ? 0.0 : 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self startAnimation];
                     }
     ];
}

- (void)stopAnimation {
    
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    self.nextButton.hidden = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kRECORD_FOR target:self selector:@selector(timerDidUpdate) userInfo:nil repeats:NO];
    CGRect originalFrame = self.progressImageView.frame;
    CGRect modifiedFrame = self.progressImageView.frame;
    modifiedFrame.size.width = 0.0f;
    self.progressImageView.frame = modifiedFrame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kRECORD_FOR];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.progressImageView.frame = originalFrame;
    [UIView commitAnimations];
    
    [self startAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.timer invalidate];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
