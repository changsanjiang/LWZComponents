//
//  LWZCollectionDecoration.h
//  LWZFoundation
//
//  Created by 畅三江 on 2021/2/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionDecoration : NSObject
@property (nonatomic, readonly) Class viewClass;
@property (nonatomic, readonly, nullable) NSBundle *viewNibBundle;
@property (nonatomic, readonly, nullable) UINib *viewNib;
@property (nonatomic, readonly) BOOL needsLayout;

- (void)setNeedsLayout NS_REQUIRES_SUPER;
- (CGRect)relativeRectThatFits:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic) NSInteger zPosition;
@end

#pragma mark - separator

typedef NS_ENUM(NSUInteger, LWZCollectionSeparatorLayoutPosition) {
    LWZCollectionSeparatorLayoutPositionBottom,
    LWZCollectionSeparatorLayoutPositionTop,
};

/// 分割线装饰.
///
/// - section: LWZCollectionSectionSeparatorDecoration
/// - header: LWZCollectionHeaderSeparatorDecoration
/// - item: LWZCollectionItemSeparatorDecoration
/// - footer: LWZCollectionFooterSeparatorDecoration
///
@interface LWZCollectionSeparatorDecoration : LWZCollectionDecoration
+ (instancetype)sectionSeparatorDecorationWithColor:(UIColor *)color height:(CGFloat)height;
+ (instancetype)headerSeparatorDecorationWithColor:(UIColor *)color height:(CGFloat)height;
+ (instancetype)itemSeparatorDecorationWithColor:(UIColor *)color height:(CGFloat)height;
+ (instancetype)footerSeparatorDecorationWithColor:(UIColor *)color height:(CGFloat)height;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic) NSInteger zPosition; // default is 10;

@property (nonatomic) LWZCollectionSeparatorLayoutPosition position; // .bottom
@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) CGFloat height;
@end

#pragma mark - background

@interface LWZCollectionBackgroundDecoration : LWZCollectionDecoration
+ (instancetype)sectionBackgroundDecorationWithBackgroundColor:(UIColor *)backgroundColor;
+ (instancetype)headerBackgroundDecorationWithBackgroundColor:(UIColor *)backgroundColor;
+ (instancetype)itemBackgroundDecorationWithBackgroundColor:(UIColor *)backgroundColor;
+ (instancetype)footerBackgroundDecorationWithBackgroundColor:(UIColor *)backgroundColor;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, strong, nullable) UIColor *backgroundColor;
@property (nonatomic) NSInteger zPosition; // default is -2;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic, strong, nullable) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;
@end
NS_ASSUME_NONNULL_END
