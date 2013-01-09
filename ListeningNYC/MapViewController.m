#import "MapViewController.h"
#import "MapWebViewController.h"
#import "AppDelegate.h"

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
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [self.mapWebViewController setMapLocation:appDelegate.currentLocation];

    }
}

#pragma mark - Map Web View & Delegate

@synthesize mapWebViewController;

- (void)mapDidLoad {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [self.mapWebViewController setMapLocation:appDelegate.currentLocation];
}

#pragma mark - Notifcations

- (void)didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (self.mapWebViewController.mapIsReady) {
        [self.mapWebViewController setMapLocation:newLocation];
    }
}

#pragma mark - Lifecycle

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
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.mapWebViewController.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapWebViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Map Web View Controller"];
    CGRect frame = self.mapWebViewController.view.frame;
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
