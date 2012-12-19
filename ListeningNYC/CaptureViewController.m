#import "CaptureViewController.h"
#import "TestMeasure.h"
#import "RadarViewController.h"

@interface CaptureViewController ()

@end

@implementation CaptureViewController

#pragma mark - IB

@synthesize radarContainerView;

#pragma mark - Radar view controller

@synthesize radarViewController, testMeasure;

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"ToolbarBackgroundA"];
    self.tabBarController.tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    UITabBarItem *tabItem = [[[self.tabBarController tabBar] items] objectAtIndex:0];
    [tabItem setFinishedSelectedImage:[UIImage imageNamed:@"Capture"] withFinishedUnselectedImage:[UIImage imageNamed:@"Capture"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // connect up the container view
    self.radarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Radar View Controller"];
    [self.radarContainerView addSubview:self.radarViewController.view];
    
	self.testMeasure = [[TestMeasure alloc] init];
    [self.testMeasure start];
    self.radarViewController.datasource = self.testMeasure;
}

- (void)viewWillUnload {
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
