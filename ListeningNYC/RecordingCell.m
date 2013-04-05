#import "RecordingCell.h"
#import "Utils.h"
#import "COSMFeedModel.h"

@interface RecordingCell() {}

@property BOOL hasLaidOutTags;

@end

@implementation RecordingCell

#pragma mark - Data

@synthesize feed, delegate;

#pragma mark - Circle bands datasource

- (float)alphaForBand:(int)bandIndex of:(int)totalBands {    return [Utils alphaForBand:bandIndex in:self.feed];
}

#pragma mark - IB

@synthesize tagContainer, dateLabel, deleteButton, circleBands, circleBandsContainer;

- (IBAction)deleteRecording:(id)sender {
    UIAlertView* message = [[UIAlertView alloc] initWithTitle: @"Delete" message:@"Are you sure you wish to delete this recoriding?" delegate:self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Delete", nil];
    [message show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cellWantsDeletion:)]) {
            [self.delegate cellWantsDeletion:self];
        }
    }
}

#pragma mark - UI

@synthesize tagViews, hasLaidOutTags;

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.hasLaidOutTags) {
        [self.tagViews enumerateObjectsUsingBlock:^(UIView *tagView, NSUInteger idx, BOOL *stop) {
            [tagView removeFromSuperview];
        }];
        self.tagViews = [Utils createSmallTagViews:[Utils tagArrayWithoutMachineTags:[Utils userTagsForRecording:self.feed]]];
        
        [Utils layoutViewsHTMLStyle:self.tagViews
                             inRect:CGRectMake(0.0f, 0.0f, self.tagContainer.frame.size.width, self.tagContainer.frame.size.height)
                        withSpacing:CGSizeMake(5.0f, 3.0f)];
        [Utils addSubviews:self.tagViews toView:self.tagContainer];
    }
    self.hasLaidOutTags = YES;
    self.deleteButton.hidden = YES;
    self.circleBands.datasource = self;
    self.circleBands.numberOfBands = 10;
    self.circleBands.drawMask = true;
    self.dateLabel.text = [Utils dataTimeOfRecording:self.feed];
    
    UIImage *circleBandImage = [Utils historyCellImageForFeed:self.feed];
    if (circleBandImage) {
        self.circleBands.isDisabled = YES;
        [self.cachedCircleBandsImageView removeFromSuperview];
        self.cachedCircleBandsImageView = [[UIImageView alloc] initWithImage:circleBandImage];
        self.cachedCircleBandsImageView.frame = self.circleBands.frame;
        [self.circleBandsContainer addSubview:self.cachedCircleBandsImageView];
    } else {
        [self.cachedCircleBandsImageView removeFromSuperview];
        self.cachedCircleBandsImageView = nil;
        [self.circleBands saveImageOnNextRender:[Utils historyCellImagePathForFeed:self.feed]];
        [self.circleBands setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    
}

- (void)swipedLeft:(id)sender {
    self.deleteButton.hidden = !self.deleteButton.hidden;
}


- (void)swipedRight:(id)sender {
    self.deleteButton.hidden = !self.deleteButton.hidden;
}

#pragma mark - Life cycle

- (void)prepareForReuse {
    [super prepareForReuse];
    self.hasLaidOutTags = NO;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.hasLaidOutTags = NO;   
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UISwipeGestureRecognizer* swipeGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
        [swipeGestureRecognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:swipeGestureRecognizerLeft];
        
        UISwipeGestureRecognizer* swipeGestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
        [swipeGestureRecognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:swipeGestureRecognizerRight];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.hasLaidOutTags = NO;
        NSLog(@"setting selection style");
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UISwipeGestureRecognizer* swipeGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
        [swipeGestureRecognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:swipeGestureRecognizerLeft];
        
        UISwipeGestureRecognizer* swipeGestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
        [swipeGestureRecognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:swipeGestureRecognizerRight];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
