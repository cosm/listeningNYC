#import "AddTagViewController.h"
#import "Utils.h"
#import "CustomUserTags.h"

@interface AddTagViewController ()

@end

@implementation AddTagViewController

#pragma mark - Data

@synthesize tableView, suggestedTags, customTags;

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    [self.suggestedTags removeAllObjects];
    [self.customTags.tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
    NSMutableArray *typedTags = [Utils findTagsIn:self.textfield.text];
    [Utils addObjectsWhenNotADuplicate:typedTags to:self.customTags.tags];
    [self.customTags saveTags];
    [Utils addObjectsWhenNotADuplicate:typedTags to:self.tags];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life Cycle

- (void)keyboardDidShow:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    [Utils setHeight:self.tableView.frame.size.height - keyboardFrameBeginRect.size.height + 50.0f to:self.tableView];
}

- (void)keyboardDidHide:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    [Utils setHeight:self.tableView.frame.size.height + keyboardFrameBeginRect.size.height - 50.0f to:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.customTags) {
        self.customTags = [[CustomUserTags alloc] init];
    }
    [self.customTags loadTags];
    if (self.customTags.tags.count == 0) {
        [self.customTags.tags addObjectsFromArray:[Utils tags]];
    }
    
    self.textfield.delegate = self;
    if  (!self.suggestedTags) {
        self.suggestedTags = [[NSMutableArray alloc] initWithArray:self.customTags.tags];
    }
    
    [self.tableView reloadData];
    self.textfield.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
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

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.customTags.tags removeObjectIdenticalTo:[self.suggestedTags objectAtIndex:indexPath.row]];
        [self.suggestedTags removeObjectIdenticalTo:[self.suggestedTags objectAtIndex:indexPath.row]];
        [self.customTags saveTags];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.textfield.text = [self.suggestedTags objectAtIndex:indexPath.row];
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    [self add:tv];
}

@end
