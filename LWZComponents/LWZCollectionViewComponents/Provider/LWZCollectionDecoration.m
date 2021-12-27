//
//  LWZCollectionDecoration.m
//  LWZFoundation
//
//  Created by 畅三江 on 2021/2/22.
//

#import "LWZCollectionDecoration.h"
#import "LWZCollectionDefines.h"
 
@interface LWZCollectionDecoration ()
@property (nonatomic, readonly) id userInfo; 
@property (nonatomic) CGRect relativeRect;
@end

@implementation LWZCollectionDecoration {
    BOOL _needsLayout;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _zPosition = LWZCollectionDecorationDefaultZPosition;
        _needsLayout = YES;
    }
    return self;
}

- (Class)viewClass {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)needsLayout {
    return _needsLayout;
}

- (void)setNeedsLayout {
    _needsLayout = YES;
}

- (CGRect)relativeRectThatFits:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (CGRect)relativeRectToFit:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath {
    _needsLayout = NO;
    return [self relativeRectThatFits:rect atIndexPath:indexPath];
}

// LWZCollectionViewLayoutAttributes.decorationUserInfo
- (id)userInfo {
    return self;
}
@end


#import "LWZCollectionViewLayoutAttributes.h"

@interface LWZCollectionSeparatorDecorationView : UICollectionReusableView
@property (nonatomic, strong) UIView *contentView;
@end

@implementation LWZCollectionSeparatorDecorationView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _contentView = [UIView.alloc initWithFrame:CGRectZero];
        [self addSubview:_contentView];
        _contentView.backgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentView.frame = self.bounds;
}

- (void)applyLayoutAttributes:(LWZCollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    LWZCollectionSeparatorDecoration *separator = layoutAttributes.decorationUserInfo;
    if ( separator == nil ) return;

    _contentView.backgroundColor = separator.color;
    self.layer.zPosition = separator.zPosition;
}
@end
  
@implementation LWZCollectionSeparatorDecoration
@dynamic zPosition;

- (instancetype)initWithColor:(UIColor *)color height:(CGFloat)height {
    self = [self init];
    _color = color;
    _height = height;
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.zPosition = LWZCollectionDecorationSeparatorZPosition;
    }
    return self;
}

- (Class)viewClass {
    return LWZCollectionSeparatorDecorationView.class;
}

- (CGRect)relativeRectThatFits:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath {
    CGRect frame = rect;
    frame.size.height = _height;
    frame.origin.x += _contentInsets.left;
    frame.size.width -= _contentInsets.left + _contentInsets.right;
    switch ( _position ) {
        case LWZCollectionSeparatorLayoutPositionBottom: {
            frame.origin.y = CGRectGetMaxY(rect) - _height - _contentInsets.bottom;
        }
            break;
        case LWZCollectionSeparatorLayoutPositionTop: {
            frame.origin.y = CGRectGetMinY(rect) + _contentInsets.top;
        }
            break;
    }
    return frame;
}
@end

@implementation LWZCollectionSectionSeparatorDecoration

@end

@implementation LWZCollectionHeaderSeparatorDecoration

@end

@implementation LWZCollectionItemSeparatorDecoration

@end

@implementation LWZCollectionFooterSeparatorDecoration

@end


#pragma mark - mark

@interface LWZCollectionBackgroundDecorationView : UICollectionReusableView
@property (nonatomic, strong) UIView *contentView;
@end

@implementation LWZCollectionBackgroundDecorationView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _contentView = [UIView.alloc initWithFrame:CGRectZero];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentView.frame = self.bounds;
}

- (void)applyLayoutAttributes:(LWZCollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];

    LWZCollectionBackgroundDecoration *decoration = layoutAttributes.decorationUserInfo;
    if ( decoration == nil ) return;

    _contentView.backgroundColor = decoration.backgroundColor;
    _contentView.layer.cornerRadius = decoration.cornerRadius;
    _contentView.layer.borderColor = decoration.borderColor.CGColor;
    _contentView.layer.borderWidth = decoration.borderWidth;
    
    self.layer.zPosition = decoration.zPosition;
}
@end


@interface LWZCollectionBackgroundDecoration ()

@end

@implementation LWZCollectionBackgroundDecoration
@dynamic zPosition;


- (instancetype)initWithBackgroundColor:(UIColor *)backgroundColor {
    self = [self init];
    _backgroundColor = backgroundColor;
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.zPosition = LWZCollectionDecorationDefaultZPosition;
    }
    return self;
}
 
- (Class)viewClass {
    return LWZCollectionBackgroundDecorationView.class;
}

- (CGRect)relativeRectThatFits:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath {
    return UIEdgeInsetsInsetRect(rect, _contentInsets);
}
@end

@implementation LWZCollectionSectionBackgroundDecoration

@end

@implementation LWZCollectionHeaderBackgroundDecoration

@end

@implementation LWZCollectionItemBackgroundDecoration

@end

@implementation LWZCollectionFooterBackgroundDecoration

@end

