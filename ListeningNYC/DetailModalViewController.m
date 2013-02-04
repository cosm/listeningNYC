#import "DetailModalViewController.h"
#import "Utils.h"
#import "COSMFeedModel.h"
#import "COSMDatastreamModel.h"

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

@synthesize containerView, tagsContainer, likeDislikeSlider, mapContainer, modalBackgroundImageView, dateTimeLabel, dbLabel;

- (IBAction)close:(id)sender {
    [self.view removeFromSuperview];
}

#pragma mark - Circle Bands Datasource

- (float)alphaForBand:(int)bandIndex of:(int)totalBands {
    return [Utils valueForBand:bandIndex in:self.feed];
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
    if (self.feed) {
        self.circleBands.datasource = self;
    }
    
    // ----------
    // @todo move to layoutViews
    
    // set the tags
    NSMutableArray *tagViews = [Utils createTagViews:[Utils tagArrayWithoutMachineTags:[Utils userTagsForRecording:self.feed]]];
    
    [Utils layoutViewsVerticalCenterStyle:tagViews inRect:self.tagsContainer.frame spacingMin:1.0f spacingMax:10.0f];
    [Utils flipChildUIImageViewsIn:tagViews whichExceed:CGPointMake(10000.0f, self.tagsContainer.frame.size.height/2.0f)];
    [Utils addSubviews:tagViews toView:self.tagsContainer];
    
    float dB = [[[Utils datastreamWithId:@"Peak-dB" in:self.feed] valueForKeyPath:@"info.current_value"] floatValue];
    float dBA = [[[Utils datastreamWithId:@"Peak-dBA" in:self.feed] valueForKeyPath:@"info.current_value"] floatValue];
    float dBC = [[[Utils datastreamWithId:@"Peak-dBC" in:self.feed] valueForKeyPath:@"info.current_value"] floatValue];
    self.dbLabel.text = [NSString stringWithFormat:@"%.0fdB %.0fdBA %0.fdBC", dB, dBA, dBC];
    
    self.dateTimeLabel.text = [Utils dataTimeOfRecording:self.feed];
    
    self.likeDislikeSlider.value = [[[Utils datastreamWithId:@"LikeDislike" in:self.feed] valueForKeyPath:@"info.current_value"] floatValue];
    
    // ----------
    
    [self.likeDislikeSlider setMinimumTrackImage:[UIImage imageNamed:@"blank_tile"] forState:UIControlStateNormal];
    [self.likeDislikeSlider setMaximumTrackImage:[UIImage imageNamed:@"blank_tile"] forState:UIControlStateNormal];
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
