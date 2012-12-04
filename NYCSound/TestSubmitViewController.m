#import "TestSubmitViewController.h"
#import "Utils.h"

@interface TestSubmitViewController ()

@end

@implementation TestSubmitViewController

#pragma mark - data

@synthesize feed, db;

#pragma mark - Feed delegate

- (void)modelDidSave:(COSMModel *)model {
    NSLog(@"Model saved ok!");
    [self.loadingViewController.view removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)modelFailedToSave:(COSMModel *)model withError:(NSError*)error json:(id)JSON {
    NSLog(@"Failed to save");
    self.feed.delegate = nil;
    [Utils alertUsingJSON:JSON orTitle:@"Error saving feed" message:JSON];
}

#pragma mark - IB

@synthesize slider;

- (IBAction)saveToCOSM:(id)sender {
    COSMDatastreamModel *likeModel = [[COSMDatastreamModel alloc] init];
    [likeModel.info setValue:@"like" forKey:@"id"];
    [likeModel.info setValue:[NSString stringWithFormat:@"%f", self.slider.value] forKey:@"current_value"];
    // DbA
    COSMDatastreamModel *dbModel = [[COSMDatastreamModel alloc] init];
    [dbModel.info setValue:@"db" forKey:@"id"];
    [dbModel.info setValue:[NSString stringWithFormat:@"%f", self.db.flatDB] forKey:@"current_value"];
    [dbModel.info setValue:@"iOS Db)" forKeyPath:@"unit.label"];
    [dbModel.info setValue:@"dB" forKeyPath:@"unit.symbol"];
    // DbA
    COSMDatastreamModel *dbaModel = [[COSMDatastreamModel alloc] init];
    [dbaModel.info setValue:@"dba" forKey:@"id"];
    [dbaModel.info setValue:[NSString stringWithFormat:@"%f", self.db.aWeightedDB] forKey:@"current_value"];
    [dbaModel.info setValue:@"A-Weighted Decibles)" forKeyPath:@"unit.label"];
    [dbaModel.info setValue:@"dB" forKeyPath:@"unit.symbol"];
    // DbC
    COSMDatastreamModel *dbcModel = [[COSMDatastreamModel alloc] init];
    [dbcModel.info setValue:@"dbc" forKey:@"id"];
    [dbcModel.info setValue:[NSString stringWithFormat:@"%f", self.db.cWeightedDB] forKey:@"current_value"];
    [dbcModel.info setValue:@"C-Weighted Decibles" forKeyPath:@"unit.label"];
    [dbcModel.info setValue:@"dB" forKeyPath:@"unit.symbol"];
    // add the info to the feed
    [self.feed.datastreamCollection.datastreams addObject:likeModel];
    [self.feed.datastreamCollection.datastreams addObject:dbModel];
    [self.feed.datastreamCollection.datastreams addObject:dbaModel];
    [self.feed.datastreamCollection.datastreams addObject:dbcModel];
    
    [self.feed.info setValue:@"NYCSound Measurement" forKey:@"title"];
    self.loadingViewController = [Utils loadingViewControllerOn:self withTitle:@"Loading"];
    self.feed.delegate = self;
    
    //NSLog(@"JSON %@", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.feed.info options:NSJSONWritingPrettyPrinted error:nil]encoding:NSUTF8StringEncoding]);
    [self.feed save];
}

#pragma mark - life cycle

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
    if (!self.feed) {
        self.feed = [[COSMFeedModel alloc] init];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
