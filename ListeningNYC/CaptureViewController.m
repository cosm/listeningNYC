#import "CaptureViewController.h"
#import "TestMeasure.h"
#import "RadarViewController.h"

@interface CaptureViewController ()

@end

@implementation CaptureViewController

#pragma mark - Radar view controller

@synthesize radarViewController, testMeasure;

#pragma mark - Life Cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[RadarViewController class]]) {
        self.radarViewController = segue.destinationViewController;
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.testMeasure = [[TestMeasure alloc] init];
    [self.testMeasure start];
    self.radarViewController.datasource = self.testMeasure;
}

- (void)viewWillUnload {
    
}

- (id)init {
    if ((self = [super init])) {
        NSLog(@"init!!");
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
