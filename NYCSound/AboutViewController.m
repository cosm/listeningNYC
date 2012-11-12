//
//  AboutViewController.m
//  NYCSound
//
//  Created by Ross Cairns on 07/11/2012.
//  Copyright (c) 2012 COSM. All rights reserved.
//

#import "AboutViewController.h"
#import "COSMDefaults.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

@synthesize guidTextField;

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
    
    self.guidTextField.text = [COSMDefaults cosmGUID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

-(IBAction)cancelFilterViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
