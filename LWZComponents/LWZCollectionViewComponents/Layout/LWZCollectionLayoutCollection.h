//
//  LWZCollectionLayoutCollection.h
//  LWZAppComponents
//
//  Created by 畅三江 on 2022/4/11.
//

#import "LWZCollectionLayoutSection.h"

NS_ASSUME_NONNULL_BEGIN

@interface LWZCollectionLayoutCollection : NSObject
- (instancetype)initWithScrollDirection:(UICollectionViewScrollDirection)scrollDirection;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)enumerateSectionsUsingBlock:(void(NS_NOESCAPE ^)(LWZCollectionLayoutSection *section, BOOL *stop))block;
- (nullable NSArray<LWZCollectionLayoutSection *> *)sectionsInRect:(CGRect)rect;
- (nullable LWZCollectionLayoutSection *)sectionAtIndex:(NSInteger)index;
- (void)addSection:(LWZCollectionLayoutSection *)section;
- (void)removeAllSections;

- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (nullable LWZCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (nullable NSArray<__kindof LWZCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)param;

- (void)enumerateLayoutAttributesWithElementCategory:(UICollectionElementCategory)category usingBlock:(void(NS_NOESCAPE ^)(LWZCollectionViewLayoutAttributes *attributes, BOOL *stop))block;
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category;
- (nullable NSArray<LWZCollectionViewLayoutAttributes *> *)layoutAttributesObjectsForElementCategory:(UICollectionElementCategory)category inSection:(NSInteger)section;
@end

NS_ASSUME_NONNULL_END
