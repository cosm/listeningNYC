#import "HistoryViewController.h"
#import "DetailModalViewController.h"
#import "Utils.h"
#import "COSM.h"
#import "DeleteingViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

#pragma mark - Cosm delegate

-(void)modelDidDeleteFromCOSM:(COSMModel *)model {
    [self.deletingViewController.view removeFromSuperview];
    self.deletingViewController = nil;  
    
    unsigned int index = [self.feeds indexOfObject:model];
    if (index == NSNotFound) {
        NSLog(@"failed to find the model in the list of feeds");
        return;
    }
    
    [self.feeds removeObjectAtIndex:index];
    
    if ([self.feeds count] + [self.unsyncedFeeds count] == 0) {
        [Utils deleteFeedFromDisk:(COSMFeedModel *)model withExtension:@"recording"];
        [self.tableView reloadData];
    } else {
        [Utils deleteFeedFromDisk:(COSMFeedModel *)model withExtension:@"recording"];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }

    self.tabBarController.tabBar.userInteractionEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
}

- (void)modelFailedToDeleteFromCOSM:(COSMModel *)model withError:(NSError *)error json:(id)JSON {
    NSLog(@"feed failed to delete from COSM");
    NSLog(@"error is %@", error);
    [self.deletingViewController.view removeFromSuperview];
    self.deletingViewController = nil;
    
    if (error.code == -1009) {
        [Utils alert:@"No Internet Connection" message:@"Your recording could not be deleted"];
    } else {
        [Utils alertUsingJSON:JSON orTitle:@"Failed to deleted recording." message:@"Something went wrong."];
    }
    model.delegate = nil;
    self.tabBarController.tabBar.userInteractionEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
}

#pragma mark - Data

@synthesize feeds, unsyncedFeeds;

#pragma mark - UI

@synthesize detailModalViewController, startHereImageView;

- (void)updateDisplayStartInstructions {
    if (!self.startHereImageView && (![self.unsyncedFeeds count] && ![self.feeds count])) {
        self.startHereImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"StartHere"]];
        self.startHereImageView.contentMode = UIViewContentModeBottomLeft;
        [self.tableView addSubview:startHereImageView];
        [Utils setY:self.tableView.frame.size.height - 60.0f to:self.startHereImageView];
        [Utils setX:18.0f to:self.startHereImageView];
    } else if ([self.unsyncedFeeds count] || [self.feeds count]){
        [self.tableView removeFromSuperview];
        self.tableView = NULL;
    }
}

#pragma mark - Cell Delegate

- (void)cellWantsDeletion:(RecordingCell*)cell {
    NSIndexPath *path = [NSIndexPath indexPathForRow:[self.feeds indexOfObject:cell.feed] inSection:0];
    
    // try to find the feed in synced
    COSMFeedModel *feedToDelete = [self.feeds objectAtIndex:path.row];
    if (feedToDelete) {
        
        
        self.deletingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Deleteing View Controller"];
        self.deletingViewController.view.autoresizingMask = UIViewAutoresizingNone;
        self.deletingViewController.view.frame = [[UIScreen mainScreen] bounds];
        [self.view addSubview:self.deletingViewController.view];
        self.tabBarController.tabBar.userInteractionEnabled = NO;
        self.tableView.userInteractionEnabled = NO;
        
        
        feedToDelete.delegate = self;
        [feedToDelete deleteFromCOSM];
    }
}

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
    
    self.feeds = [Utils loadFeedsFromDiskWithExtension:@"recording"];
    self.unsyncedFeeds = [Utils loadFeedsFromDiskWithExtension:@"unsynced"];
    [self.tableView reloadData];
    
    [self updateDisplayStartInstructions];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [Utils setY:self.tableView.frame.size.height - 60.0f + self.tableView.contentOffset.y to:self.startHereImageView];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.unsyncedFeeds.count > 0) {
        switch (section) {
            case 0: return @"Recordings"; break;
            case 1: return @"Unsynced Recordings"; break;
        }
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.unsyncedFeeds.count > 0) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return MAX([self.feeds count], 1); break;
        case 1: return [self.unsyncedFeeds count]; break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recording Cell";
    static NSString *CellIdentifierNoSamples = @"No Samples";
    UITableViewCell *returnCell;
    if ([self.unsyncedFeeds count] >0 || [self.feeds count] >0) {
        RecordingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        COSMFeedModel *feed = [self.feeds objectAtIndex:indexPath.row];
        cell.feed = feed;
        cell.delegate = self;
        [cell setNeedsDisplay];
        returnCell = cell;
    } else {
        NSLog(@"creating a no samples cell");
        returnCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNoSamples];
    }
    returnCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return returnCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105.0f;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

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
    if ([self.feeds count] > 0 || [self.unsyncedFeeds count] > 0) {
        self.detailModalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Detail Modal View Controller"];
        if (indexPath.section == 0) {
            self.detailModalViewController.feed = [self.feeds objectAtIndex:indexPath.row];
        } else {
            self.detailModalViewController.feed = [self.unsyncedFeeds objectAtIndex:indexPath.row];
        }
        [self.view.superview.superview addSubview:detailModalViewController.view];
        [self.view.superview.superview bringSubviewToFront:detailModalViewController.view];
        [self.detailModalViewController viewWillAppear:NO];
    }
}

@end
