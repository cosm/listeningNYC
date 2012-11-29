#import "MeasureDetailViewController.h"
#import "LoadingViewController.h"
#import "Utils.h"

@interface MeasureDetailViewController ()

@end

@implementation MeasureDetailViewController

#pragma mark - Options

@synthesize dBA, dBC, feed, mapView;

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
    [self.loadingViewController.view removeFromSuperview];       
}

#pragma mark - IB

@synthesize measureAt, soundIs, likeDislike;

- (IBAction)save:(id)sender {
    
    // check for missing info
    NSMutableString *alertMessage = [NSMutableString stringWithString:@""];
    if (self.measureAt.text == nil || [self.measureAt.text isEqualToString:@""]) {
        [alertMessage appendString:@"Add where the sound was measured. "];
    } 
    if (self.soundIs.text == nil || [self.soundIs.text isEqualToString:@""]) {
        [alertMessage appendString:@"Add what the sound is. "];
    }
    // alert missing info
    if (![alertMessage isEqualToString:@""]) {
        [Utils alert:@"Missing info" message:alertMessage];
        return;
    }
    
    // Measure at
    COSMDatastreamModel *measureAtModel = [[COSMDatastreamModel alloc] init];
    [measureAtModel.info setValue:@"measureAt" forKey:@"id"];
    [measureAtModel.info setValue:self.measureAt.text forKey:@"current_value"];
    // Sound is
    COSMDatastreamModel *soundIsModel = [[COSMDatastreamModel alloc] init];
    [soundIsModel.info setValue:@"soundIs" forKey:@"id"];
    [soundIsModel.info setValue:self.soundIs.text forKey:@"current_value"];
    // likeDislike is
    COSMDatastreamModel *likeModel = [[COSMDatastreamModel alloc] init];
    [likeModel.info setValue:@"like" forKey:@"id"];
    [likeModel.info setValue:[NSString stringWithFormat:@"%f", self.likeDislike.value] forKey:@"current_value"];
    // DbA
    COSMDatastreamModel *dbaModel = [[COSMDatastreamModel alloc] init];
    [dbaModel.info setValue:@"dba" forKey:@"id"];
    [dbaModel.info setValue:[NSString stringWithFormat:@"%f", dBA] forKey:@"current_value"];
    //[dbaModel.info setValue:@"A-Weighted Decibles" forKeyPath:@"unit.type"];
    [dbaModel.info setValue:@"A-Weighted Decibles)" forKeyPath:@"unit.label"];
    [dbaModel.info setValue:@"dB" forKeyPath:@"unit.symbol"];
    // DbB
    COSMDatastreamModel *dbcModel = [[COSMDatastreamModel alloc] init];
    [dbcModel.info setValue:@"dbb" forKey:@"id"];
    [dbcModel.info setValue:[NSString stringWithFormat:@"%f", dBC] forKey:@"current_value"];
    [dbcModel.info setValue:@"C-Weighted Decibles" forKeyPath:@"unit.label"];
    [dbcModel.info setValue:@"dB" forKeyPath:@"unit.symbol"];
    // add the info to the feed
    [self.feed.datastreamCollection.datastreams addObject:measureAtModel];
    [self.feed.datastreamCollection.datastreams addObject:soundIsModel];
    [self.feed.datastreamCollection.datastreams addObject:likeModel];
    [self.feed.datastreamCollection.datastreams addObject:dbaModel];
    [self.feed.datastreamCollection.datastreams addObject:dbcModel];

    
    [self.feed.info setValue:@"NYCSound Measurement" forKey:@"title"];
    self.loadingViewController = [Utils loadingViewControllerOn:self withTitle:@"Loading"];
    self.feed.delegate = self;
    
    NSLog(@"JSON %@", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.feed.info options:NSJSONWritingPrettyPrinted error:nil]encoding:NSUTF8StringEncoding]);
    [self.feed save];
}


#pragma mark - UI

- (void)keyboardDidShow:(NSNotification *)notification
{
#pragma warning - should be getting detailed information about the height of the keyboard
    CGRect rect =  [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //NSLog(@"%@", [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]);
    
    //Assign new frame to your view
    [self.view setFrame:CGRectMake(0,-127.0f,320,460)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.
    
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.view setFrame:CGRectMake(0,20.0f,320,460)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Life Cycle

- (void)viewWillDisappear:(BOOL)animated {
    self.feed.delegate = nil;
     [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.feed) {
        self.feed = [[COSMFeedModel alloc] init];
    }
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if (!dBA || !dBC) {
        [Utils alert:@"dBA / dBC" message:@"Values not found"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
