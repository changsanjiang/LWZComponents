//
//  LWZCollectionItem.h
//  LWZAppComponents
//
//  Created by 蓝舞者 on 2021/8/25.
//

#import "LWZCollectionDefines.h"
@class LWZCollectionSection, LWZCollectionDecoration;

NS_ASSUME_NONNULL_BEGIN
/**
 LWZCollectionItem 主要职责: 根据模型层对`视图配置`及`视图交互事件传递`等均可在此部分中实现.
 
 视图层不宜添加复杂的业务逻辑, 为了使视图达到最大程度的复用,
 可以改变一下方式, 采用 item 的形式,
 对于同一个cell, 不同复用场景 可以这样 不同业务可以做不同的item, 但对应的可以是同一个 cell.
 
 视图只管显示对应数据或传递触发事件,
 */
@interface LWZCollectionItem : NSObject
@property (nonatomic, readonly) Class cellClass;
@property (nonatomic, readonly, nullable) NSBundle *cellNibBundle;
@property (nonatomic, readonly, nullable) UINib *cellNib;
@property (nonatomic, readonly) BOOL needsLayout;

@property (nonatomic) NSInteger zPosition;
@property (nonatomic, strong, nullable) LWZCollectionDecoration *decoration;

- (void)setNeedsLayout NS_REQUIRES_SUPER;
- (CGSize)layoutSizeThatFits:(CGSize)size inSection:(nullable LWZCollectionSection *)section atIndexPath:(nullable NSIndexPath *)indexPath scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

- (void)bindCell:(__kindof UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)unbindCell:(__kindof UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy, nullable) void(^selectionHandler)(__kindof LWZCollectionItem *item, NSIndexPath *indexPath);

@property (nonatomic, copy, nullable) void(^deselectionHandler)(__kindof LWZCollectionItem *item, NSIndexPath *indexPath);
@end

@interface LWZCollectionItem (LWZCollectionViewWeightLayoutAdditions)
@property (nonatomic) CGFloat weight;
@end

@interface LWZCollectionItem (LWZCollectionViewListLayoutAdditions)
@property (nonatomic) LWZCollectionLayoutAlignment layoutAlignment;
@end

@interface LWZCollectionItem (LWZCollectionSubclassHooks)
- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath;
- (void)didDeselectAtIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
