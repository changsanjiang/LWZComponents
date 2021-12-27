//
//  LWZAttributeLabel.m
//  Pods
//
//  Created by changsanjiang on 2020/2/23.
//

#import "CommonLabel.h"

@implementation CommonLabel
- (void)layoutSubviews {
    [super layoutSubviews];
    if ( _layoutSubviewsExeBlock ) _layoutSubviewsExeBlock(self);
}
 
#pragma mark -

- (void)drawTextInRect:(CGRect)rect {
    rect.origin.x += _contentInsets.left;
    rect.size.width -= _contentInsets.left + _contentInsets.right;
    rect.origin.y += _contentInsets.top;
    rect.size.height -= _contentInsets.top + _contentInsets.bottom;
    [super drawTextInRect:rect];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    if ( self.text.length != 0 ) {
        bounds.size.width -= _contentInsets.left + _contentInsets.right;
        bounds.size.height -= _contentInsets.top + _contentInsets.bottom;
    }
    
    if ( bounds.size.width < 0 || bounds.size.height < 0 )
        return CGRectZero;
    
    CGRect rect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    if ( self.text.length != 0 ) {
        rect.size.width += _contentInsets.left + _contentInsets.right;
        rect.size.height += _contentInsets.top + _contentInsets.bottom;
    }
    return rect;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    if ( !UIEdgeInsetsEqualToEdgeInsets(contentInsets, _contentInsets) ) {
        _contentInsets = contentInsets;
        [self setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}

@end
 
@implementation CommonLabel (CommonIBSupported)
- (void)setTopInset:(CGFloat)topInset {
    if ( topInset != _contentInsets.top ) {
        _contentInsets.top = topInset;
        [self setNeedsDisplay];
    }
}
- (CGFloat)topInset {
    return _contentInsets.top;
}

- (void)setLeftInset:(CGFloat)leftInset {
    if ( leftInset != _contentInsets.left ) {
        _contentInsets.left = leftInset;
        [self setNeedsDisplay];
    }
}
- (CGFloat)leftInset {
    return _contentInsets.left;
}

- (void)setBottomInset:(CGFloat)bottomInset {
    if ( bottomInset != _contentInsets.bottom ) {
        _contentInsets.bottom = bottomInset;
        [self setNeedsDisplay];
    }
}
- (CGFloat)bottomInset {
    return _contentInsets.bottom;
}

- (void)setRightInset:(CGFloat)rightInset {
    if ( rightInset != _contentInsets.right ) {
        _contentInsets.right = rightInset;
        [self setNeedsDisplay];
    }
}
- (CGFloat)rightInset {
    return _contentInsets.right;
}
@end
