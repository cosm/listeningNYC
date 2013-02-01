#import "CaptureViewController.h"
#import "SoundAnalyser.h"
#import "RadarViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "PostCaptureViewController.h"

@interface CaptureViewController ()

@end

@implementation CaptureViewController

#pragma mark - Recording View Controller 

@synthesize recordingViewController, recordingContainerView, cosmFeed;

- (void)recordingViewControllerDidCancel {
    [self.view bringSubviewToFront:self.startButton];
    [self.recordingViewController.view removeFromSuperview];
    self.recordingViewController.delegate = nil;
    self.recordingViewController = nil;
    self.startButton.hidden = NO;
    
    [self.startButton setUserInteractionEnabled:YES];
    [self.countdownHolder setUserInteractionEnabled:NO];
    [self.recordingContainerView setUserInteractionEnabled:NO];
    
    [self.radarViewController reset];
    [self.radarViewController start];
}

- (void)recordingViewControllerDidFinish {
    self.cosmFeed = [self.soundAnalyser stopRecording];
    [self.radarViewController stop];
    [self.radarViewController requestAllFromDatasource];
}

- (void)recordingViewControllerDidRequestNext {
    [self.recordingViewController.view removeFromSuperview];
    self.recordingViewController.delegate = nil;
    self.recordingViewController = nil;
    self.startButton.hidden = NO;
    
    [self.startButton setUserInteractionEnabled:YES];
    [self.countdownHolder setUserInteractionEnabled:NO];
    [self.recordingContainerView setUserInteractionEnabled:NO];
    
    PostCaptureViewController *postCaptureViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Post Capture View Controller"];
    postCaptureViewController.cosmFeed = self.cosmFeed;
    self.cosmFeed = nil;
    [self.navigationController pushViewController:postCaptureViewController animated:YES];
}

#pragma mark - Countdown View Controller

@synthesize countdownViewController, countdownHolder;

- (void)countdownViewControllerDidCountdown {
    [self.countdownViewController.view removeFromSuperview];
    self.countdownViewController.delegate = nil;
    self.countdownViewController = nil;
    
    // display the recording view controller
    self.recordingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Recording View Controller"];
    //[Utils setY:0.0f to:self.recordingContainerView];
    [self.recordingContainerView addSubview:self.recordingViewController.view];
    self.recordingViewController.view.frame = CGRectMake(0.0f, 0.0f, 278.0f, 146.0f);
    self.recordingViewController.delegate = self;
    
    [self.startButton setUserInteractionEnabled:NO];
    [self.countdownHolder setUserInteractionEnabled:NO];
    [self.recordingContainerView setUserInteractionEnabled:YES];
    [self.soundAnalyser beginRecording];
    
    [self.radarViewController reset];
    
}

#pragma mark - IB

@synthesize radarContainerView, startButton;

- (IBAction)startButtonPressed:(id)sender {
    self.countdownViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Countdown View Controller"];
    [Utils setY:0.0f to:self.countdownViewController.view];
    self.countdownViewController.delegate = self;
    [self.countdownHolder addSubview:self.countdownViewController.view];
    self.startButton.hidden = YES;
    
    [self.startButton setUserInteractionEnabled:NO];
    [self.countdownHolder setUserInteractionEnabled:YES];
    [self.recordingContainerView setUserInteractionEnabled:NO];
}

#pragma mark - Radar view controller

@synthesize radarViewController, soundAnalyser;

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"ToolbarBackgroundA"];
    self.tabBarController.tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    UITabBarItem *tabItem = [[[self.tabBarController tabBar] items] objectAtIndex:0];
    [tabItem setFinishedSelectedImage:[UIImage imageNamed:@"Capture"] withFinishedUnselectedImage:[UIImage imageNamed:@"Capture"]];
    
    [self.soundAnalyser start];
    self.radarViewController.datasource = self.soundAnalyser;
    [self.radarViewController viewWillAppear:animated];
    
    [self.radarViewController reset];
    [self.radarViewController start];
    
    [self.countdownViewController.view removeFromSuperview];
    self.countdownViewController.delegate = nil;
    self.countdownViewController = nil;
    
    [self.recordingViewController.view removeFromSuperview];
    self.recordingViewController.delegate = nil;
    self.recordingViewController = nil;
    
    self.startButton.hidden = NO;
    
    [self.startButton setUserInteractionEnabled:YES];
    [self.countdownHolder setUserInteractionEnabled:NO];
    [self.recordingContainerView setUserInteractionEnabled:NO];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"CaptureViewController viewWillDisappear");
    [self.radarViewController viewWillDisappear:animated];
    [self.soundAnalyser stop];
}

- (void)viewDidLoad {
    NSLog(@"Radar View Controller view did load");
    [super viewDidLoad];
    
    // connect up the container view
    self.radarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Radar View Controller"];
    [self.radarContainerView addSubview:self.radarViewController.view];
    
	self.soundAnalyser = [[SoundAnalyser alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kApplicationDidBecomeActive object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.soundAnalyser start];
        self.radarViewController.datasource = self.soundAnalyser;
        [self.radarViewController viewWillAppear:NO];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kapplicationWillResignActive object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.radarViewController viewWillDisappear:NO];
        [self.soundAnalyser stop];
    }];
}

- (void)viewWillUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"Captuer View Controller initWithCoder");
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"Captuer View Controller initWithNibName");
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
