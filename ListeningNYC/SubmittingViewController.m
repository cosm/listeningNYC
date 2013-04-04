#import "SubmittingViewController.h"

@interface SubmittingViewController ()

@end

@implementation SubmittingViewController

#pragma mark - Delegate

@synthesize delegate;

#pragma mark - IB

@synthesize successContainerView, submittingContainerView, spinner;

- (IBAction)okPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(submittingSoundViewControllerDidComplete:)]) {
        [self.delegate submittingSoundViewControllerDidComplete:self];
    }
}

#pragma mark - Control

- (void)showSubmitting {
    self.submittingContainerView.hidden = NO;
    self.successContainerView.hidden = YES;
    [self.spinner startAnimating];
}

- (void)showSuccess {
    self.submittingContainerView.hidden = YES;
    self.successContainerView.hidden = NO;
    [self.spinner stopAnimating];
}

#pragma mark - Lifecycle

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
