#import <UIKit/UIKit.h>
@class CustomUserTags;

@interface AddTagViewController : UIViewController<UITextFieldDelegate>

// Tags to be provided but the pushing view controller;
@property (nonatomic, weak) NSMutableArray *tags;

// Table data
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *suggestedTags;
@property (nonatomic, strong) CustomUserTags *customTags;

// Text Field Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

// IB
@property (nonatomic, weak) IBOutlet UITextField *textfield;
- (IBAction)cancel:(id)sender;
- (IBAction)add:(id)sender;

@end
