#import "PostCaptureViewController.h"
#import "AddTagViewController.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "ISO8601DateFormatter.h"

@interface PostCaptureViewController ()

@end

@implementation PostCaptureViewController

#pragma mark - Data

@synthesize tags, elevation;

#pragma mark - COSM Model

@synthesize cosmFeed;

- (void)modelDidSave:(COSMModel *)model {
    COSMFeedModel *feed = (COSMFeedModel *)model;
    [Utils saveFeedToDisk:feed withExtension:@"recording"];
    [self.submittingViewController showSuccess];
    self.navigationController.tabBarController.tabBar.userInteractionEnabled = YES;
}

- (void)modelFailedToSave:(COSMModel *)model withError:(NSError*)error json:(id)JSON {
    NSLog(@"Failed to save model");
    NSLog(@"JSON is %@", JSON);
    NSLog(@"Error is %@", error);
    NSLog(@"Error code %d", error.code);
    COSMFeedModel *feed = (COSMFeedModel *)model;
    
    [self.submittingViewController.view removeFromSuperview];
    self.submittingViewController.delegate = nil;
    self.submittingViewController = nil;
    
    if (error.code == -1009) {
        if (kSTORE_UNSYNCED) {
            [Utils alert:@"No Internet Connection" message:@"Your recording will be synced later"];
            [Utils saveUnsyncedFeedToDisk:feed withExtension:@"unsynced"];
        } else {
            [Utils alert:@"No Internet Connection" message:@"Your recording was not saved"];
        }
    } else {
        [Utils alertUsingJSON:JSON orTitle:@"Failed to save recording." message:@"Something went wrong."];
    }
    //[self.navigationController popViewControllerAnimated:YES];
    self.cosmFeed.delegate = nil;
    self.navigationController.tabBarController.tabBar.userInteractionEnabled = YES;
}

#pragma mark - Notifcations

- (void)didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (self.mapWebViewController.mapIsReady) {
        [self.mapWebViewController setMapLocation:newLocation];
    }
    elevation = newLocation.altitude;
}

#pragma mark - Submitting View Controller Delegate

- (void)submittingSoundViewControllerDidComplete:(SubmittingViewController *)submittingViewController {
    [self.submittingViewController.view removeFromSuperview];
    self.submittingViewController.delegate = nil;
    self.submittingViewController = nil;
    [self.tabBarController setSelectedIndex:2];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Map Web View Delegate

- (void)mapDidLoad {
    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    [self.mapWebViewController setMapLocation:((AppDelegate *)appDelegate).currentLocation];
}

#pragma mark - Circle Bands Datasource

- (float)alphaForBand:(int)bandIndex of:(int)totalBands {
    return [Utils valueForBand:bandIndex in:self.cosmFeed];
}

#pragma mark - IB

@synthesize circleBands, tagsContainer, slider;

- (IBAction)deleteTagsTouched:(id)sender {
    [self addDeleteButtons];
}


- (IBAction)cancel:(id)sender {
    self.cosmFeed.delegate = nil;
    self.cosmFeed = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submit:(id)sender {
    NSLog(@"should disable submit button");
    // instead
    if (!self.cosmFeed.delegate) {
        
        // Default data
        [self.cosmFeed.info setObject:[NSString stringWithFormat:@"%@ %@", kCOSM_FEED_TITLE_PREPEND, [Utils describeArray:self.tags]] forKey:@"title"];
        [self.cosmFeed.info setObject:kCOSM_FEED_WEBSITE forKey:@"website"];
        [self.cosmFeed.info setObject:[Utils versionString] forKey:@"version"];
        NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
        [location setObject:@"mobile" forKey:@"disposition"];
        CLLocationCoordinate2D coordinate = self.mapWebViewController.queryMapLocation;
        [location setObject:[NSString stringWithFormat:@"%f", coordinate.latitude] forKey:@"lat"];
        [location setObject:[NSString stringWithFormat:@"%f", coordinate.longitude] forKey:@"lon"];
        if (self.elevation > -10000000.0) {
            [location setObject:[NSString stringWithFormat:@"%f", self.elevation] forKey:@"ele"];
        }
        [self.cosmFeed.info setObject:location forKey:@"location"];
        
        // Post capture data
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        NSArray *machineTags = @[
            [NSString stringWithFormat:@"User:GUID=%@", [Utils deviceGUID]],
            [NSString stringWithFormat:@"App:Version=%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]],
            [NSString stringWithFormat:@"App:Build=%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]],
            [NSString stringWithFormat:@"App:Device=%@", [Utils platformString]],
            [NSString stringWithFormat:@"Created:Date=%@", [dateFormatter stringFromDate:[NSDate date]]]
        ];
        [self.tags addObjectsFromArray:machineTags];
        [self.cosmFeed.info setObject:self.tags forKey:@"tags"];
        
        COSMDatastreamModel *likeDislike = [[COSMDatastreamModel alloc] init];
        [likeDislike.info setValue:@"LikeDislike" forKeyPath:@"id"];
        [likeDislike.info setValue:[NSString stringWithFormat:@"%f", self.slider.value] forKeyPath:@"current_value"];
        [self.cosmFeed.datastreamCollection.datastreams addObject:likeDislike];
        
        // add the submit screen
        self.submittingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Submitting View Controller"];
        self.submittingViewController.view.autoresizingMask = UIViewAutoresizingNone;
        self.submittingViewController.view.frame = [[UIScreen mainScreen] bounds];
        [self.submittingViewController showSubmitting];
        self.submittingViewController.delegate = self;
        [self.view addSubview:self.submittingViewController.view];
        
        self.cosmFeed.delegate = self;
        [self.cosmFeed save];
        self.navigationController.tabBarController.tabBar.userInteractionEnabled = NO;
    }
}

- (IBAction)locate:(id)sender {
    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    [self.mapWebViewController setMapIsTracking:YES];
    [self.mapWebViewController setMapLocation:((AppDelegate *)appDelegate).currentLocation];
}

#pragma mark - UI

@synthesize tagViews, deleteButtons, submittingViewController;

- (void)layoutTags {    
    // remove all the tags & delete buttond
    [[self.tagsContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.deleteButtons enumerateObjectsUsingBlock:^(TagDeleteView *deleteView, NSUInteger idx, BOOL *stop) {
        deleteView.delegate = nil;
    }];
    [self.deleteButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.deleteButtons removeAllObjects];
    
    self.tagViews = [Utils createBiggerTagViews:[Utils tagArrayWithoutMachineTags:self.tags]];
    [Utils layoutViewsVerticalCenterStyle:self.tagViews inRect:self.tagsContainer.frame spacingMin:1.0f spacingMax:20.0f];
    [Utils flipChildUIImageViewsIn:self.tagViews whichExceed:CGPointMake(10000.0f, self.tagsContainer.frame.size.height / 2.0f)];
    [Utils addSubviews:self.tagViews toView:self.tagsContainer];
}

- (void)addDeleteButtons {
    [self layoutTags]; // <-- inefficient, but gives a clean slate for now
    
    [self.tagViews enumerateObjectsUsingBlock:^(UIView *tagView, NSUInteger idx, BOOL *stop) {
        CGPoint position = CGPointMake(self.tagsContainer.frame.origin.x, self.tagsContainer.frame.origin.y + tagView.frame.origin.y);
        TagDeleteView *deleteView = [[TagDeleteView alloc] initWithOrigin:position tag:[self.tags objectAtIndex:idx] upImage:[UIImage imageNamed:@"DeleteButton"] selectedImage:[UIImage imageNamed:@"DeleteButtonPressed"]];
        deleteView.delegate = self;
        [self.view addSubview:deleteView];
        [self.deleteButtons addObject:deleteView];
    }];
}

#pragma mark - Tag Delete Delegate

- (void)tagDeleteView:(TagDeleteView *)sender requestsDeletionOf:(NSString *)tag {
    NSLog(@"should be deleteing a tag!! %@", tag);
    [self.tags removeObject:tag];
    sender.delegate = nil;
    [self layoutTags];
}

#pragma mark - Life Cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[AddTagViewController class]]) {
        AddTagViewController *addTagViewController = segue.destinationViewController;
        addTagViewController.tags = self.tags;
    }
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
    self.elevation = -10000000.0;
    self.mapWebViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Map Web View Controller"];
    [self.view addSubview:self.mapWebViewController.view];
    [self.view sendSubviewToBack:self.mapWebViewController.view];
    CGRect frame = self.mapWebViewController.view.frame;
    frame.origin.y = 0.0f;
    self.mapWebViewController.view.frame = frame;
    self.circleBands.circleDiameter = 156.0f;
    self.circleBands.numberOfBands = 10;
    self.tags = [[NSMutableArray alloc] init];
    self.deleteButtons = [[NSMutableArray alloc] init];
    [self.slider setMinimumTrackImage:[UIImage imageNamed:@"SliderTrack"] forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:[UIImage imageNamed:@"SliderTrack"] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage imageNamed:@"SliderThumb"] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    self.circleBands.datasource = self;
    [self layoutTags];
    self.mapWebViewController.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kLocationUpdatedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self didUpdateToLocation:[note.userInfo valueForKeyPath:@"newLocation"] fromLocation:[note.userInfo valueForKeyPath:@"oldLocation"]];
    }];
    
    // tab bar
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"ToolbarBackgroundA"];
    self.tabBarController.tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    UITabBarItem *tabItem = [[[self.tabBarController tabBar] items] objectAtIndex:0];
    [tabItem setFinishedSelectedImage:[UIImage imageNamed:@"Capture"] withFinishedUnselectedImage:[UIImage imageNamed:@"Capture"]];
}

- (void)viewWillDisappear:(BOOL)animated {    
    self.circleBands.datasource = nil;
    self.mapWebViewController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
