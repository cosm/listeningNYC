#import <UIKit/UIKit.h>

/// protocol
@class TagDeleteView;
@protocol TagDeleteViewDelegate <NSObject>
@optional
- (void)tagDeleteView:(TagDeleteView *)sender requestsDeletionOf:(NSString *)tag;
@end

@interface TagDeleteView : UIView
// life cycle
- (id)initWithOrigin:(CGPoint)origin tag:(NSString *)tag upImage:(UIImage *)upImage selectedImage:(UIImage *)selectedImage;
// data
@property (nonatomic, copy) NSString *tagname;
@property (nonatomic, weak) id<TagDeleteViewDelegate> delegate;
@end
