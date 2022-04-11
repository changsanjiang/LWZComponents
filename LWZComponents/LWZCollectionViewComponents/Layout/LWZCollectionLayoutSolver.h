//
//  LWZCollectionLayoutSolver.h
//  mssapp_Example
//
//  Created by 畅三江 on 2022/4/8.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "LWZCollectionDefines.h"
#import "UICollectionViewLayoutAttributes+LWZCollectionAdditions.h"
#import "LWZCollectionLayoutContainer.h"

NS_ASSUME_NONNULL_BEGIN
@interface LWZCollectionLayoutSolver : NSObject

- (instancetype)initWithLayout:(id<LWZCollectionLayout>)layout;

@property (nonatomic, weak, readonly, nullable) __kindof id<LWZCollectionLayout> layout;

// header footer

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryItemWithKind:(NSString *)kind indexPath:(NSIndexPath *)indexPath offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container;

// items

- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForItemsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container; // normal presentation mode

- (nullable UIView *)layoutCustomViewForItemsWithSection:(NSInteger)section offset:(CGFloat)offset container:(LWZSectionLayoutContainer *)container; // custom presentation mode

// decorations

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForDecorationItemWithCategory:(LWZCollectionDecorationCategory)category inRect:(CGRect)rect indexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - weight layout solver

@protocol LWZCollectionWeightLayout <LWZCollectionLayout>
- (CGFloat)layoutWeightForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface LWZCollectionWeightLayoutSolver : LWZCollectionLayoutSolver

@end


#pragma mark - list layout solver

@protocol LWZCollectionListLayout <LWZCollectionLayout>
- (LWZCollectionLayoutAlignment)layoutAlignmentForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface LWZCollectionListLayoutSolver : LWZCollectionLayoutSolver

@end

#pragma mark - waterfall flow layout solver

@protocol LWZCollectionWaterfallFlowLayout <LWZCollectionLayout>
- (NSInteger)layoutNumberOfArrangedItemsPerLineInSection:(NSInteger)section;
@end

@interface LWZCollectionWaterfallFlowLayoutSolver : LWZCollectionLayoutSolver

@end

#pragma mark - restricted layout solver

@interface LWZCollectionRestrictedLayoutSolver : LWZCollectionLayoutSolver

@end


#pragma mark - template layout solver

@protocol LWZCollectionTemplateLayout <LWZCollectionLayout>
- (NSArray<LWZCollectionTemplateGroup *> *)layoutTemplateContainerGroupsInSection:(NSInteger)section;
@end

@interface LWZCollectionTemplateLayoutSolver : LWZCollectionLayoutSolver

@end


#pragma mark - multiple layout solver

@protocol LWZCollectionMultipleLayout <
    LWZCollectionWeightLayout,
    LWZCollectionListLayout,
    LWZCollectionWaterfallFlowLayout,
    LWZCollectionTemplateLayout
>
- (LWZCollectionLayoutType)layoutTypeForItemsInSection:(NSInteger)section;
@end

@interface LWZCollectionMultipleLayoutSolver : LWZCollectionLayoutSolver
- (Class)solverClassForLayoutType:(LWZCollectionLayoutType)layoutType;
@end


#pragma mark - compositional layout solver
@class LWZCollectionViewLayout;

@protocol LWZCollectionCompositionalLayout <LWZCollectionMultipleLayout>
- (BOOL)isOrthogonalScrollingInSection:(NSInteger)section;
- (CGSize)layoutSizeToFit:(CGSize)fittingSize forOrthogonalContentInSection:(NSInteger)section scrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (LWZCollectionLayoutContentOrthogonalScrollingBehavior)orthogonalContentScrollingBehaviorInSection:(NSInteger)section;
@end

@interface LWZCollectionCompositionalLayoutSolver : LWZCollectionMultipleLayoutSolver

- (instancetype)initWithLayout:(LWZCollectionViewLayout<LWZCollectionCompositionalLayout> *)layout;

@end
NS_ASSUME_NONNULL_END
