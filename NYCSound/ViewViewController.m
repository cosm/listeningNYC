//
//  ViewViewController.m
//  NYCSound
//
//  Created by Ross Cairns on 07/11/2012.
//  Copyright (c) 2012 COSM. All rights reserved.
//

#import "ViewViewController.h"
#import "COSMDefaults.h"

@interface ViewViewController ()

@end

@implementation ViewViewController

@synthesize mapWebView;

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
    
    self.navigationItem.rightBarButtonItem.tintColor = [COSMDefaults colorForKey:@"orange"];
    
    [self.mapWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://rossc1.cartodb.com/tables/untitled_table/embed_map"]]];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
