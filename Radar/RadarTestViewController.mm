#import "RadarTestViewController.h"
#import "TestMeasure.h"
#import "RadarViewController.h"

@interface RadarTestViewController ()

@end

@implementation RadarTestViewController

#pragma mark - Radar view controller

@synthesize radarViewController, testMeasure;

#pragma mark - Life Cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Radar View Controller"]) {
        self.radarViewController = segue.destinationViewController;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.testMeasure = [[TestMeasure alloc] init];
    [self.testMeasure start];
}

- (void)viewWillUnload {
    
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
