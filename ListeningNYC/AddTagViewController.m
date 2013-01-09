#import "AddTagViewController.h"
#import "Utils.h"

@interface AddTagViewController ()

@end

@implementation AddTagViewController

#pragma mark - Data

@synthesize tableView, suggestedTags;

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    [self.suggestedTags removeAllObjects];
    [[Utils tags] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSRange substringRange = [obj rangeOfString:substring];
            if (substringRange.location == 0) {
                [self.suggestedTags addObject:obj];
            }
        }
    }];
    [self.tableView reloadData];
}

#pragma mark - Text Feild Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}

#pragma mark - IB

@synthesize textfield;

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self add:textfield];
    return YES;
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)add:(id)sender {
    [Utils addObjectsWhenNotADuplicate:[Utils findTagsIn:self.textfield.text] to:self.tags];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    self.textfield.delegate = self;
    if  (!self.suggestedTags) {
        self.suggestedTags = [[NSMutableArray alloc] initWithArray:[Utils tags]];
    }
    
    [self.tableView reloadData];
    self.textfield.delegate = self;
    [self.textfield becomeFirstResponder];
    
    // tab bar
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"ToolbarBackgroundA"];
    self.tabBarController.tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    UITabBarItem *tabItem = [[[self.tabBarController tabBar] items] objectAtIndex:0];
    [tabItem setFinishedSelectedImage:[UIImage imageNamed:@"Capture"] withFinishedUnselectedImage:[UIImage imageNamed:@"Capture"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.suggestedTags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.suggestedTags objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18.0f];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.textfield.text = [self.suggestedTags objectAtIndex:indexPath.row];
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    [self add:tv];
}

@end
