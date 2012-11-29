#import "MeasureViewController.h"
#import "MeasureDetailViewController.h"
#include <stdlib.h>

@interface MeasureViewController ()

@end

@implementation MeasureViewController

#pragma mark - Data

@synthesize dBA, dBC, dbAButton, dbCButton;

float randomDB() {
    return (((float)arc4random()/0x100000000)*120);
};

#pragma mark - Life cycle

- (void)viewWillAppear:(BOOL)animated {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
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
    
    if (dBA == 0.0f && dBC == 0.0f) {
        dBA = randomDB();
        dBC = randomDB();
    }
    
    dbAButton.title = [NSString stringWithFormat:@"%.0f dB(A)", dBA];
    dbCButton.title = [NSString stringWithFormat:@"%.0f dB(C)", dBC];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue:: %@", [segue identifier]);
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"Measure Data"])
    {
        // Get reference to the destination view controller
        MeasureDetailViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.dBA = dBA;
        vc.dBC = dBC;
    }
}

@end
