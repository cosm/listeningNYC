#import "CountdownViewController.h"

@interface CountdownViewController ()

@end

@implementation CountdownViewController

#pragma mark - Counter

@synthesize timer, state;

- (void)timerDidUpdate {
    switch (self.state) {
        case 1: {
            self.imageView.image = [UIImage imageNamed:@"Capture2"];
            self.state = 2;
            break;
        }
        case 2: {
            self.imageView.image = [UIImage imageNamed:@"Capture1"];
            self.state = 3;
            break;
        }
        case 3: {
            [self.timer invalidate];
            self.timer = nil;
            if (self.delegate && [self.delegate respondsToSelector:@selector(countdownViewControllerDidCountdown)]) {
                [self.delegate countdownViewControllerDidCountdown];
            }
            break;
        }
        default:
            NSLog(@"RemainQuietViewController::timerDidUpdate reached an known state");
            break;
    }
}

#pragma mark - IB

@synthesize okButton, imageView, delegate;

- (IBAction)okPressed:(id)sender {
    self.okButton.hidden = YES;
    self.state = 1;
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kRECORD_COUNTDOWN_FOR target:self selector:@selector(timerDidUpdate) userInfo:nil repeats:YES];
    self.imageView.image = [UIImage imageNamed:@"Capture3"];
}

#pragma mark - Life cycle

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear said Countdown");
    [self.timer invalidate];
    self.imageView.image = [UIImage imageNamed:@"RemainQuiet"];
    self.okButton.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear said Countdown");
    [self.timer invalidate];
    self.okButton.hidden = NO;
    self.imageView.image = [UIImage imageNamed:@"RemainQuiet"];
    self.state = 0;
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
