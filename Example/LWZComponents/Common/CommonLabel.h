//
//  LWZAttributeLabel.h
//  Pods
//
//  Created by changsanjiang on 2020/2/23.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface CommonLabel : UILabel
@property (nonatomic, copy, nullable) void(^layoutSubviewsExeBlock)(__kindof CommonLabel *label);

///
/// 配置文本区域inset
///
///     当设置了富文本垂直方向不起作用时, 请设置段落的lineBreakMode.
///
@property (nonatomic) UIEdgeInsets contentInsets;
@end

#if TARGET_INTERFACE_BUILDER
@interface CommonLabel (CommonIBSupported)
@property (nonatomic) IBInspectable CGFloat topInset;
@property (nonatomic) IBInspectable CGFloat leftInset;
@property (nonatomic) IBInspectable CGFloat bottomInset;
@property (nonatomic) IBInspectable CGFloat rightInset;
@end
#endif
NS_ASSUME_NONNULL_END
