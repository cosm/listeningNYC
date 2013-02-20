#import "MapViewController.h"
#import "MapWebViewController.h"
#import "AppDelegate.h"
#import "DetailModalViewController.h"

@interface MapViewController ()
@property BOOL optionsIsVisible;
@property float webContainerHeightWhenVisible;
@end

@implementation MapViewController

#pragma mark - UI

@synthesize optionsIsVisible, webContainerHeightWhenVisible;

- (void)toggleMapOptionsAnimated:(BOOL)animated {
    [self setMapOptionsVisible:!self.optionsIsVisible animated:animated];
}

- (void)setMapOptionsVisible:(BOOL)visible animated:(BOOL)animated {
    if (self.optionsIsVisible == visible) {
        return;
    }
    if (animated) {
        [UIView beginAnimations:nil context:nil];
    }
    if (visible) {
        CGRect frame = self.webContainerView.frame;
        frame.size.height = webContainerHeightWhenVisible;
        self.webContainerView.frame = frame;
    } else {
        CGRect frame = self.webContainerView.frame;
        frame.size.height = self.view.frame.size.height;
        self.webContainerView.frame = frame;
    }
    if (animated) {
        [UIView commitAnimations];
    }
    self.optionsIsVisible = visible;
}

#pragma mark - IB

@synthesize webContainerView;

- (IBAction)toggleMapOptionsPressed:(id)sender {
    [self toggleMapOptionsAnimated:YES];
}

- (IBAction)locatePressed:(id)sender {
    if (self.mapWebViewController.mapIsReady) {
        [self.mapWebViewController setMapIsTracking:YES];
        id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
        [self.mapWebViewController setMapLocation:((AppDelegate *)appDelegate).currentLocation];
    }
}

- (IBAction)filterChanged:(id)sender {
    UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
    NSLog(@"Filter");
    switch ([segmentControl selectedSegmentIndex]) {
        case 0:
            [self.mapWebViewController setMapQueryType:@"likeonly"];
            break;
        case 1:
            [self.mapWebViewController setMapQueryType:@"dislikeonly"];
            break;
        case 2:
            [self.mapWebViewController setMapQueryType:@"all"];
            break;
    }
}

#pragma mark - Map Web View & Delegate

@synthesize mapWebViewController;

- (void)mapDidLoad {
    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    [self.mapWebViewController setMapLocation:((AppDelegate *)appDelegate).currentLocation];
    [self.mapWebViewController setMapQueryType:@"all"];
}

- (void)featureClicked:(id)data {
    NSString *feedIdString = [data valueForKeyPath:@"feed_id"];
    if (!feedIdString) { return; }
    
    if (!self.detailModalViewController) {
        self.detailModalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Detail Modal View Controller"];
    }
    NSLog(@"Data %@", data);
    [self.detailModalViewController fetchFeedWithId:[feedIdString integerValue]];
    CGRect frame = detailModalViewController.view.frame;
    frame.origin.y = 0.0f;
    detailModalViewController.view.frame = frame;
    [self.view addSubview:detailModalViewController.view];
    [self.detailModalViewController viewWillAppear:NO];
    [detailModalViewController.view setAlpha:0.0f];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [detailModalViewController.view  setAlpha:1.0];
    [UIView commitAnimations];
}

#pragma mark - Notifcations

- (void)didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (self.mapWebViewController.mapIsReady) {
        [self.mapWebViewController setMapLocation:newLocation];
    }
}

#pragma mark - Lifecycle

@synthesize detailModalViewController;

- (void)viewWillAppear:(BOOL)animated {
    // tab bar
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"ToolbarBackgroundB"];
    self.tabBarController.tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    UITabBarItem *tabItem = [[[self.tabBarController tabBar] items] objectAtIndex:1];
    [tabItem setFinishedSelectedImage:[UIImage imageNamed:@"Map"] withFinishedUnselectedImage:[UIImage imageNamed:@"Map"]];

    if (!self.webContainerHeightWhenVisible) {
        self.webContainerHeightWhenVisible = self.webContainerView.frame.size.height;
        self.optionsIsVisible = YES;
        [self setMapOptionsVisible:NO animated:NO];
    }
    
    self.mapWebViewController.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kLocationUpdatedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self didUpdateToLocation:[note.userInfo valueForKeyPath:@"newLocation"] fromLocation:[note.userInfo valueForKeyPath:@"oldLocation"]];
    }];
    [self.detailModalViewController viewWillAppear:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.mapWebViewController.delegate = nil;
    [self.detailModalViewController viewWillDisappear:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapWebViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Map Web View Controller"];
    NSLog(@"Map View Controller Did Load");
    CGRect frame = self.webContainerView.frame;
    frame.origin = CGPointMake(0.0f, 0.0f);
    self.mapWebViewController.view.frame = frame;
    
    [self.webContainerView addSubview:self.mapWebViewController.view];
    [self.webContainerView sendSubviewToBack:self.mapWebViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
