#import "DeleteingViewController.h"

@interface DeleteingViewController ()

@end

@implementation DeleteingViewController

#pragma mark - IB

@synthesize spinner;

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.spinner startAnimating];
}

@end
