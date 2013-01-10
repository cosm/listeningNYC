#import "PostCaptureViewController.h"
#import "CircleBands.h"
#import "AddTagViewController.h"
#import "Utils.h"
#import "AppDelegate.h"

@interface PostCaptureViewController ()

@end

@implementation PostCaptureViewController

#pragma mark - Data

@synthesize tags;

#pragma mark - Notifcations

- (void)didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (self.mapWebViewController.mapIsReady) {
        [self.mapWebViewController setMapLocation:newLocation];
    }
}

#pragma mark - Map Web View Delegate

- (void)mapDidLoad {
    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    [self.mapWebViewController setMapLocation:((AppDelegate *)appDelegate).currentLocation];
}

#pragma mark - IB

@synthesize circleBands, tagsContainer, slider;

- (IBAction)deleteTagsTouched:(id)sender {
    [self addDeleteButtons];
}

- (IBAction)submit:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UI

@synthesize tagViews, deleteButtons;

- (void)layoutTags {
    // remove all the tags & delete buttond
    [[self.tagsContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.deleteButtons enumerateObjectsUsingBlock:^(TagDeleteView *deleteView, NSUInteger idx, BOOL *stop) {
        deleteView.delegate = nil;
    }];
    [self.deleteButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.deleteButtons removeAllObjects];
    
    self.tagViews = [Utils createBiggerTagViews:self.tags];
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
    self.mapWebViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Map Web View Controller"];
    [self.view addSubview:self.mapWebViewController.view];
    [self.view sendSubviewToBack:self.mapWebViewController.view];
    CGRect frame = self.mapWebViewController.view.frame;
    frame.origin.y = 0.0f;
    self.mapWebViewController.view.frame = frame;
    self.circleBands.circleDiameter = 156.0f;
    self.tags = [[NSMutableArray alloc] init];
    self.deleteButtons = [[NSMutableArray alloc] init];
    [self.slider setMinimumTrackImage:[UIImage imageNamed:@"SliderTrack"] forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:[UIImage imageNamed:@"SliderTrack"] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage imageNamed:@"SliderThumb"] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
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
    self.mapWebViewController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
