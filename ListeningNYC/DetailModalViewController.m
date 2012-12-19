#import "DetailModalViewController.h"
#import "CircleBands.h"
#import "Utils.h"

@interface DetailModalViewController ()

@end

@implementation DetailModalViewController

#pragma mark - IB

@synthesize containerView, webview, tagsContainer;

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
    
    // Debug create tags
    NSArray *tags = @[@"One tag", @"Two Tags", @"Very long tags here", @"longer tags"];
    NSMutableArray *tagViews = [Utils createTagViews:tags];
    
    [Utils layoutViewsVerticalCenterStyle:tagViews inRect:self.tagsContainer.frame spacingMin:1.0f spacingMax:10.0f];
    [Utils flipChildUIImageViewsIn:tagViews whichExceed:CGPointMake(10000.0f, self.tagsContainer.frame.size.height/2.0f)];
    [Utils addSubviews:tagViews toView:self.tagsContainer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
