#import "CaptureViewController.h"
#import "SoundAnalyser.h"
#import "RadarViewController.h"
#import "AppDelegate.h"

@interface CaptureViewController ()

@end

@implementation CaptureViewController

#pragma mark - IB

@synthesize radarContainerView;

#pragma mark - Radar view controller

@synthesize radarViewController, soundAnalyser;

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"CaptureViewController viewWillAppear");
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"ToolbarBackgroundA"];
    self.tabBarController.tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    UITabBarItem *tabItem = [[[self.tabBarController tabBar] items] objectAtIndex:0];
    [tabItem setFinishedSelectedImage:[UIImage imageNamed:@"Capture"] withFinishedUnselectedImage:[UIImage imageNamed:@"Capture"]];
    
    [self.soundAnalyser start];
    self.radarViewController.datasource = self.soundAnalyser;
    [self.radarViewController viewWillAppear:animated];
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
