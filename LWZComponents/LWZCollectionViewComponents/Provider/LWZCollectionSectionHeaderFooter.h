//
//  LWZCollectionSectionHeaderFooter.h
//  LWZAppComponents
//
//  Created by changsanjiang on 2021/8/25.
//

#import <UIKit/UIKit.h>
@class LWZCollectionSection, LWZCollectionDecoration;

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionSectionHeaderFooter : NSObject
@property (nonatomic, readonly) Class viewClass;
@property (nonatomic, readonly, nullable) NSBundle *viewNibBundle;
@property (nonatomic, readonly, nullable) UINib *viewNib;
@property (nonatomic, readonly) BOOL needsLayout;

- (void)setNeedsLayout NS_REQUIRES_SUPER;
- (CGSize)layoutSizeThatFits:(CGSize)size inSection:(__kindof LWZCollectionSection *)section atIndex:(NSInteger)index scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

@property (nonatomic) NSInteger zPosition;
@property (nonatomic, strong, nullable) LWZCollectionDecoration *decoration;

- (void)bindView:(__kindof UICollectionReusableView *)view inSection:(NSInteger)section;
- (void)unbindView:(__kindof UICollectionReusableView *)view inSection:(NSInteger)section;
@end
NS_ASSUME_NONNULL_END
