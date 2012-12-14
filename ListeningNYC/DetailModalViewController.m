#import "DetailModalViewController.h"
#import "CircleBands.h"

@interface DetailModalViewController ()

@end

@implementation DetailModalViewController

#pragma mark - IB

@synthesize containerView, webview;

- (IBAction)close:(id)sender {
    [self.view removeFromSuperview];
}

#pragma mark - Life cycle

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
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"public/map" ofType:@"html"] isDirectory:NO]]];
    self.circleBands.circleDiameter = 156.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
