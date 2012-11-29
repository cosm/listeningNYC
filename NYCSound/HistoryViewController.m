#import "HistoryViewController.h"
#import "HistoryCell.h"
#import "Utils.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

#pragma mark - Data

@synthesize feedCollection;

#pragma mark - Collection Delegate

- (void)feedCollectionDidFetch:(COSMFeedCollection *)feedCollection {
    [self.tableView reloadData];
}

- (void)feedCollectionFailedToFetch:(COSMFeedCollection *)feedCollection withError:(NSError*)error json:(id)JSON {
    [Utils alertUsingJSON:JSON orTitle:@"Error saving feed" message:JSON];
}

#pragma mark - Life cycle

- (void)viewWillDisappear:(BOOL)animated {
    self.feedCollection.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.feedCollection.delegate = self;
    [self.feedCollection fetch];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.feedCollection) {
        self.feedCollection = [[COSMFeedCollection alloc] init];
        [self.feedCollection useParameter:@"user" withValue:@"nycsoundapp"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.feedCollection.feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"History Cell";
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    COSMFeedModel *feed = [self.feedCollection.feeds objectAtIndex:indexPath.row];
    cell.label.text = [feed valueForKeyPath:@"info.title"];
    
    return cell;
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
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Measurement"];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
