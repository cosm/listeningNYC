#import "ViewViewController.h"
#import "COSMDefaults.h"

@interface ViewViewController ()

@end

@implementation ViewViewController

@synthesize mapView;

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Wiew will appear with map %@", self.mapView);
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
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
    
    self.navigationItem.rightBarButtonItem.tintColor = [COSMDefaults colorForKey:@"orange"];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
