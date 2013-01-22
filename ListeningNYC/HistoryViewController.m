#import "HistoryViewController.h"
#import "TwinCell.h"
#import "DetailModalViewController.h"
#import "Utils.h"
#import "COSM.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

#pragma mark - Data

@synthesize feeds;

#pragma mark - UI

@synthesize detailModalViewController;

#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    // tab bar
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"ToolbarBackgroundC"];
    self.tabBarController.tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    UITabBarItem *tabItem = [[[self.tabBarController tabBar] items] objectAtIndex:2];
    [tabItem setFinishedSelectedImage:[UIImage imageNamed:@"MyCollection"] withFinishedUnselectedImage:[UIImage imageNamed:@"MyCollection"]];
    
    if (self.detailModalViewController) {
        [self.detailModalViewController viewWillAppear:animated];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.detailModalViewController) {
        [self.detailModalViewController viewWillDisappear:animated];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorColor = [UIColor clearColor];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.feeds = [Utils loadFeedsFromDisk];
    return [self.feeds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Twin Cell";
    TwinCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    COSMFeedModel *feed = [self.feeds objectAtIndex:indexPath.row];
    NSLog(@"feed.info %@", feed.info);
    // Configure the cell...
    //NSDictionary *tags = [feeds valueForKeyPath:@"info.tags"]'
    //if (feed.info )
    cell.tagStrings_left = [feed.info valueForKeyPath:@"tags"];
    cell.tagStrings_right = @[@"Cars", @"Pubs", @"Rock", @"Screaming", @"Very long indeed"];
    [cell setNeedsDisplay];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105.0f;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.detailModalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Detail Modal View Controller"];
    [self.view.superview.superview addSubview:detailModalViewController.view];
    [self.view.superview.superview bringSubviewToFront:detailModalViewController.view];
    [self.detailModalViewController viewWillAppear:NO];
}

@end
