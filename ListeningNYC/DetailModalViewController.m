#import "DetailModalViewController.h"
#import "CircleBands.h"
#import "Utils.h"
#import "COSMFeedModel.h"

@interface DetailModalViewController ()

@end

@implementation DetailModalViewController

#pragma mark - Data

@synthesize feed;

#pragma mark - Map 

@synthesize mapWebViewController;

- (void)mapDidLoad {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[self.feed valueForKeyPath:@"info.location.lat"] floatValue] longitude:[[self.feed valueForKeyPath:@"info.location.lon"] floatValue]];
    NSLog(@"Lat is %@", [self.feed valueForKeyPath:@"info.location.lat"]);
    NSLog(@"Lon is %@", [self.feed valueForKeyPath:@"info.location.lon"]);
    [self.mapWebViewController setMapLocation:location];
    [self.mapWebViewController setMapZoom:[NSNumber numberWithInt:14]];
    [self.mapWebViewController setMapDisplayLocationCircle:NO];
}

#pragma mark - IB

@synthesize containerView, tagsContainer, likeDislikeSlider, mapContainer, modalBackgroundImageView;

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
    self.mapWebViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Map Web View Controller"];
    [self.mapContainer addSubview:self.mapWebViewController.view];
    [self.containerView sendSubviewToBack:self.mapContainer];
    [self.containerView sendSubviewToBack:self.modalBackgroundImageView];
    CGRect frame = self.mapContainer.frame;
    frame.origin.x = 0.0f;
    frame.origin.y = 0.0f;
    self.mapWebViewController.view.frame = frame;
    self.circleBands.circleDiameter = 156.0f;
    
    NSMutableArray *tagViews = [Utils createTagViews:[Utils tagArrayWithoutMachineTags:[self.feed.info valueForKeyPath:@"tags"]]];
    
    [Utils layoutViewsVerticalCenterStyle:tagViews inRect:self.tagsContainer.frame spacingMin:1.0f spacingMax:10.0f];
    [Utils flipChildUIImageViewsIn:tagViews whichExceed:CGPointMake(10000.0f, self.tagsContainer.frame.size.height/2.0f)];
    [Utils addSubviews:tagViews toView:self.tagsContainer];
    
    
    [self.likeDislikeSlider setMinimumTrackImage:[UIImage imageNamed:@"Blank"] forState:UIControlStateNormal];
    [self.likeDislikeSlider setMaximumTrackImage:[UIImage imageNamed:@"Blank"] forState:UIControlStateNormal];
    [self.likeDislikeSlider setThumbImage:[UIImage imageNamed:@"SliderThumb"] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    self.mapWebViewController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.mapWebViewController.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
