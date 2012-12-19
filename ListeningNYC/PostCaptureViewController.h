#import <UIKit/UIKit.h>
#import "TagDeleteView.h"
@class CircleBands;

@interface PostCaptureViewController : UIViewController<TagDeleteViewDelegate>

// Data
@property (nonatomic, strong) NSMutableArray *tags;

// IB
@property (nonatomic, weak) IBOutlet CircleBands *circleBands;
@property (nonatomic, weak) IBOutlet UIView *tagsContainer;
@property (nonatomic, weak) IBOutlet UIWebView *webview;
@property (nonatomic, weak) IBOutlet UISlider *slider;
- (IBAction)deleteTagsTouched:(id)sender;
- (IBAction)submit:(id)sender;

// UI
@property (nonatomic, weak) NSMutableArray *tagViews;
@property (nonatomic, strong) NSMutableArray *deleteButtons;
- (void)layoutTags;

// Tag Delete Delegate
- (void)tagDeleteView:(TagDeleteView *)sender requestsDeletionOf:(NSString *)tag;

@end
