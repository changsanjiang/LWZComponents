//
//  CommonTextLayoutSize.h
//  LWZAppComponents
//
//  Created by changsanjiang on 2021/8/27.
//

#import <UIKit/UIKit.h>
@class LWZTextContainer;

NS_ASSUME_NONNULL_BEGIN
@interface NSString (CommonTextLayoutSizeAdditions)
- (CGSize)lwz_layoutSizeThatFits:(CGSize)sizeLimit font:(UIFont *)font limitedToNumberOfLines:(NSInteger)limitedToNumberOfLines;
@end

@interface NSAttributedString (CommonTextLayoutSizeAdditions)
- (CGSize)lwz_layoutSizeThatFits:(CGSize)sizeLimit limitedToNumberOfLines:(NSInteger)limitedToNumberOfLines;
- (LWZTextContainer *)lwz_textContainerWithLayoutSizeThatFits:(CGSize)size limitedToNumberOfLines:(NSInteger)limitedToNumberOfLines;
- (LWZTextContainer *)lwz_textContainerWithLayoutSizeThatFits:(CGSize)size limitedToNumberOfLines:(NSInteger)limitedToNumberOfLines fixesSingleLineSpacing:(BOOL)fixesSingleLineSpacing;
@end

@interface LWZTextContainer : NSObject
@property (nonatomic, readonly) NSAttributedString *text;
/// text布局宽高.
///
/// 注意: 单行时高度不包含 lineSpacing; 如果要在单行 UILabel 上显示, label的布局高度需要考虑加上 lineSpacing;
///\code
///     CGFloat lineSpacing = ...;
///     if ( container.numberOfLines == 1 ) {
///         CGSize layoutSize = container.layoutSize;
///         layoutSize.height += lineSpacing;
///     }
///\endcode
///
@property (nonatomic, readonly) CGSize layoutSize;
@property (nonatomic, readonly) NSInteger numberOfLines;
@end
NS_ASSUME_NONNULL_END
