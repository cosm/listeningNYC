#import "TestMonitorViewController.h"
#import "TestSubmitViewController.h"
#import "TestMeasure.h"

@interface TestMonitorViewController ()

@end

@implementation TestMonitorViewController

#pragma mark - Data

@synthesize measure;

#pragma mark - UI

@synthesize dBValue, dBAValue, dBCValue, peakdBValue, peakdBAValue, peakdBCValue;

- (IBAction)touched:(id)sender {
    TestSubmitViewController *submitViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Test Submit View Controller"];
    submitViewController.db = self.measure.peakLevels;
    [self.navigationController pushViewController:submitViewController animated:YES];
}



#pragma mark - Utils

@synthesize updateTimer;

#pragma mark - Life Cycle

- (void)update {
    self.dBValue.text = [NSString stringWithFormat:@"%.0f", self.measure.currentLevels.flatDB];
    self.dBAValue.text = [NSString stringWithFormat:@"%.0f", self.measure.currentLevels.aWeightedDB];
    self.dBCValue.text = [NSString stringWithFormat:@"%.0f", self.measure.currentLevels.cWeightedDB];
    self.peakdBValue.text = [NSString stringWithFormat:@"%.0f peak dB", self.measure.peakLevels.flatDB];
    self.peakdBAValue.text = [NSString stringWithFormat:@"%.0f peak db(A)", self.measure.peakLevels.aWeightedDB];
    self.peakdBCValue.text = [NSString stringWithFormat:@"%.0f peak db(C)", self.measure.peakLevels.cWeightedDB];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.measure start];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.measure stop];
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.measure = [[TestMeasure alloc] init];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UINavigationBar-COSM-Title"]];
    [self update];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
