#import "PostCaptureViewController.h"
#import "CircleBands.h"
#import "AddTagViewController.h"
#import "Utils.h"

@interface PostCaptureViewController ()

@end

@implementation PostCaptureViewController

#pragma mark - Data

@synthesize tags;

#pragma mark - IB

@synthesize webview, circleBands, tagsContainer, slider;

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
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"public/map" ofType:@"html"] isDirectory:NO]]];
    self.circleBands.circleDiameter = 156.0f;
    self.tags = [[NSMutableArray alloc] init];
    self.deleteButtons = [[NSMutableArray alloc] init];
    [self.slider setMinimumTrackImage:[UIImage imageNamed:@"SliderTrack"] forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:[UIImage imageNamed:@"SliderTrack"] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage imageNamed:@"SliderThumb"] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [self layoutTags];
    
    // tab bar
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"ToolbarBackgroundA"];
    self.tabBarController.tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    UITabBarItem *tabItem = [[[self.tabBarController tabBar] items] objectAtIndex:0];
    [tabItem setFinishedSelectedImage:[UIImage imageNamed:@"Capture"] withFinishedUnselectedImage:[UIImage imageNamed:@"Capture"]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
