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
- (instancetype)initWithColor:(UIColor *)color height:(CGFloat)height;
@property (nonatomic) NSInteger zPosition; // default is 10;

@property (nonatomic) LWZCollectionSeparatorLayoutPosition position; // .bottom
@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) CGFloat height;
@end

/// Section
@interface LWZCollectionSectionSeparatorDecoration : LWZCollectionSeparatorDecoration

@end

/// Header
@interface LWZCollectionHeaderSeparatorDecoration : LWZCollectionSeparatorDecoration

@end

/// Item
@interface LWZCollectionItemSeparatorDecoration : LWZCollectionSeparatorDecoration

@end

/// Footer
@interface LWZCollectionFooterSeparatorDecoration : LWZCollectionSeparatorDecoration

@end

#pragma mark - background

@interface LWZCollectionBackgroundDecoration : LWZCollectionDecoration
- (instancetype)initWithBackgroundColor:(UIColor *)backgroundColor;
@property (nonatomic, strong, nullable) UIColor *backgroundColor;
@property (nonatomic) NSInteger zPosition; // default is -2;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic, strong, nullable) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;
@end

/// Section
@interface LWZCollectionSectionBackgroundDecoration : LWZCollectionBackgroundDecoration

@end

/// Header
@interface LWZCollectionHeaderBackgroundDecoration : LWZCollectionBackgroundDecoration

@end

/// Item
@interface LWZCollectionItemBackgroundDecoration : LWZCollectionBackgroundDecoration

@end

/// Footer
@interface LWZCollectionFooterBackgroundDecoration : LWZCollectionBackgroundDecoration

@end
NS_ASSUME_NONNULL_END
