#import "RecordingViewController.h"
#import "OHAttributedLabel.h"
#import "OHASBasicMarkupParser.h"
#import "Utils.h"
#import "COSM.h"

@interface RecordingViewController ()

@end

@implementation RecordingViewController

#pragma mark - Label

float maxValue(NSRange range, NSArray *array) {
    float max = -10000.0f;
    for (int i = range.location; i < range.location + range.length; ++i) {
        float floatValue = [[array objectAtIndex:i] floatValue];
        if (max < floatValue) { max = floatValue; }
    }
    return max;
}

- (void)setDescriptionUsingFeed:(COSMFeedModel*)feed {
    
    NSArray *alphas = @[
        [NSNumber numberWithFloat:[Utils alphaForBand:0 in:feed]],
        [NSNumber numberWithFloat:[Utils alphaForBand:1 in:feed]],
        [NSNumber numberWithFloat:[Utils alphaForBand:2 in:feed]],
        [NSNumber numberWithFloat:[Utils alphaForBand:3 in:feed]],
        [NSNumber numberWithFloat:[Utils alphaForBand:4 in:feed]],
        [NSNumber numberWithFloat:[Utils alphaForBand:5 in:feed]],
        [NSNumber numberWithFloat:[Utils alphaForBand:6 in:feed]],
        [NSNumber numberWithFloat:[Utils alphaForBand:7 in:feed]],
        [NSNumber numberWithFloat:[Utils alphaForBand:8 in:feed]],
        [NSNumber numberWithFloat:[Utils alphaForBand:9 in:feed]]
    ];
    
    NSString *lowDescriptor = @"a lot of";
    float lowMax = maxValue(NSMakeRange(0, 5), alphas);
    if (lowMax < 0.7) { lowDescriptor = @"some"; }
    if (lowMax < 0.2) { lowDescriptor = @"almost no"; }
    NSLog(@"low max %f", lowMax);
    
    NSString *midDescriptor = @"a lot of";
    float midMax = maxValue(NSMakeRange(4, 4), alphas);
    if (midMax < 0.8f) { midDescriptor = @"some"; }
    if (midMax < 0.3f) { midDescriptor = @"almost no"; }
    NSLog(@"mid max %f", midMax);
    
    NSString *highDescriptor = @"a lot of";
    float highMax = maxValue(NSMakeRange(8, 2), alphas);
    if (highMax < 0.5f) { highDescriptor = @"some"; }
    if (highMax < 0.35f) { highDescriptor = @"almost no"; }
    NSLog(@"high max %f", highMax);
    
    NSString *allDescriptor = @"very loud";
    float peak_db  = maxValue(NSMakeRange(0, 10), alphas);
    if (peak_db < 0.95f) { allDescriptor = @"loud"; }
    if (peak_db < 0.9f) { allDescriptor = @"moderately loud"; }
    if (peak_db < 0.6734f) { allDescriptor = @"quiet"; }
    if (peak_db < 0.2f) { allDescriptor = @"very quiet"; }
    NSLog(@"all max %f", peak_db);
    
    NSString *markedUpString = [NSString stringWithFormat:kDESCRIPTION, lowDescriptor, midDescriptor, highDescriptor, allDescriptor];
    self.descriptionLabel.attributedText = [OHASBasicMarkupParser attributedStringByProcessingMarkupInString:markedUpString];
}

#pragma mark - Timing

@synthesize delegate, timer;

- (void)timerDidUpdate {
    [self.timer invalidate];
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingViewControllerDidFinish)]) {
        [self.delegate recordingViewControllerDidFinish];
    }
    self.nextButton.hidden = NO;
    self.audioDescriptionImageView.hidden = NO;
}

#pragma mark - IB

@synthesize progressImageView, textImageView, nextButton, audioDescriptionImageView, descriptionLabel;

- (IBAction)cancelRecordingPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingViewControllerDidCancel)]) {
        [self.delegate recordingViewControllerDidCancel];
    }
}

- (IBAction)nextPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingViewControllerDidRequestNext)]) {
        [self.delegate recordingViewControllerDidRequestNext];
    }
}

#pragma mark - Animate Recording Text

- (void)startAnimation {
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         self.textImageView.alpha = (self.textImageView.alpha > 0.5) ? 0.0 : 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self startAnimation];
                     }
     ];
}

- (void)stopAnimation {
    
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    self.nextButton.hidden = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kRECORD_FOR target:self selector:@selector(timerDidUpdate) userInfo:nil repeats:NO];
    CGRect originalFrame = self.progressImageView.frame;
    CGRect modifiedFrame = self.progressImageView.frame;
    modifiedFrame.size.width = 0.0f;
    self.progressImageView.frame = modifiedFrame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kRECORD_FOR];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.progressImageView.frame = originalFrame;
    [UIView commitAnimations];

    self.audioDescriptionImageView.hidden = YES;
    
    [self startAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.timer invalidate];
}

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
