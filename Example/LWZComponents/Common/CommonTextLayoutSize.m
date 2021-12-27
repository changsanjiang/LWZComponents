//
//  CommonTextLayoutSize.m
//  LWZAppComponents
//
//  Created by changsanjiang on 2021/8/27.
//

#import "CommonTextLayoutSize.h"
 
@implementation NSString (CommonTextLayoutSizeAdditions)
- (CGSize)lwz_layoutSizeThatFits:(CGSize)sizeLimit font:(UIFont *)font limitedToNumberOfLines:(NSInteger)limitedToNumberOfLines {
    return [[NSAttributedString.alloc initWithString:self attributes:@{
        NSFontAttributeName : font
    }] lwz_layoutSizeThatFits:sizeLimit limitedToNumberOfLines:limitedToNumberOfLines];
}
@end

@implementation LWZTextContainer
- (instancetype)initWithText:(NSAttributedString *)text layoutSize:(CGSize)size numberOfLines:(NSInteger)numberOfLines {
    self = [super init];
    if ( self ) {
        _text = text;
        _layoutSize = size;
        _numberOfLines = numberOfLines;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"LWZTextContainer:<%p> { text: %@, layoutSize: %@, numberOfLines: %ld}", self, _text, NSStringFromCGSize(_layoutSize), (long)_numberOfLines];
}
@end

typedef NSValue LWZRangeValueKey;
typedef NSNumber LWZLineBreakModeNumber;
static NSAttributedStringKey const LWZNSOriginalFontAttributeName = @"NSOriginalFont";

@implementation NSAttributedString (CommonTextLayoutSizeAdditions)
- (CGSize)lwz_layoutSizeThatFits:(CGSize)sizeLimit limitedToNumberOfLines:(NSInteger)limitedToNumberOfLines {
    CGSize retv = CGSizeZero;
    if ( self.length != 0 ) {
        NSMutableAttributedString *layoutText = [NSMutableAttributedString.alloc initWithAttributedString:self];
        [layoutText enumerateAttribute:NSFontAttributeName inRange:(NSRange){0, self.length} options:NSAttributedStringEnumerationReverse usingBlock:^(UIFont *_Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if ( value == nil ) return;
            [layoutText addAttribute:LWZNSOriginalFontAttributeName value:value range:range];
        }];
        
        NSTextContainer *textContainer = [NSTextContainer.alloc initWithSize:sizeLimit];
        textContainer.lineFragmentPadding = 0;
        textContainer.maximumNumberOfLines = limitedToNumberOfLines;

        NSLayoutManager *layoutManager = [NSLayoutManager.alloc init];
        [layoutManager addTextContainer:textContainer];
        
        NSTextStorage *textStorage = [NSTextStorage.alloc initWithAttributedString:layoutText];
        [textStorage enumerateAttributesInRange:(NSRange){0, layoutText.length} options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            if ( range.length == 0 ) return;
            NSParagraphStyle *style = attrs[NSParagraphStyleAttributeName];
            if ( style == nil ) return;
            NSMutableParagraphStyle *m = [style mutableCopy];
            m.lineBreakMode = 0;
            [textStorage removeAttribute:NSParagraphStyleAttributeName range:range];
            [textStorage addAttribute:NSParagraphStyleAttributeName value:m range:range];
        }];
        [textStorage addLayoutManager:layoutManager];
        
        CGFloat scale = UIScreen.mainScreen.scale;
        (void)[layoutManager glyphRangeForTextContainer:textContainer];
        retv = [layoutManager usedRectForTextContainer:textContainer].size;
        retv.width = ceil(retv.width * scale) * (1.0 / scale);
        retv.height = ceil(retv.height * scale) * (1.0 / scale);
    }
    return retv;
}

- (LWZTextContainer *)lwz_textContainerWithLayoutSizeThatFits:(CGSize)size limitedToNumberOfLines:(NSInteger)limitedToNumberOfLines {
    return [self lwz_textContainerWithLayoutSizeThatFits:size limitedToNumberOfLines:limitedToNumberOfLines fixesSingleLineSpacing:NO];
}


- (LWZTextContainer *)lwz_textContainerWithLayoutSizeThatFits:(CGSize)size limitedToNumberOfLines:(NSInteger)limitedToNumberOfLines fixesSingleLineSpacing:(BOOL)fixesSingleLineSpacing {
    NSTextContainer *container = [NSTextContainer.alloc initWithSize:size];
    container.lineFragmentPadding = 0;
    container.maximumNumberOfLines = limitedToNumberOfLines;
    container.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSMutableAttributedString *layoutText = [NSMutableAttributedString.alloc initWithAttributedString:self];
    [layoutText enumerateAttribute:NSFontAttributeName inRange:(NSRange){0, self.length} options:NSAttributedStringEnumerationReverse usingBlock:^(UIFont *_Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ( value == nil ) return;
        [layoutText addAttribute:LWZNSOriginalFontAttributeName value:value range:range];
    }];
    
    NSMutableDictionary<LWZRangeValueKey *, LWZLineBreakModeNumber *> *lineBreakModes = NSMutableDictionary.dictionary;
    __block BOOL hasCustomLineSpacing = NO;
    [layoutText enumerateAttribute:NSParagraphStyleAttributeName inRange:(NSRange){0, self.length} options:NSAttributedStringEnumerationReverse usingBlock:^(NSParagraphStyle *_Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ( value == nil ) return;
        if ( value.lineSpacing != 0 ) {
            hasCustomLineSpacing = YES;
        }

        NSMutableParagraphStyle *style = [value mutableCopy];
        lineBreakModes[[LWZRangeValueKey valueWithRange:range]] = @(style.lineBreakMode);
        style.lineBreakMode = 0;
        [layoutText removeAttribute:NSParagraphStyleAttributeName range:range];
        [layoutText addAttribute:NSParagraphStyleAttributeName value:style range:range];
    }];
    
    // 获取宽高
    NSTextStorage *storage = [NSTextStorage.alloc initWithAttributedString:layoutText];
    NSLayoutManager *manager = [NSLayoutManager.alloc init];
    [manager addTextContainer:container];
    [storage addLayoutManager:manager];
    CGSize layoutSize = CGSizeZero;
    CGFloat scale = UIScreen.mainScreen.scale;
    [manager glyphRangeForTextContainer:container];
    layoutSize = [manager usedRectForTextContainer:container].size;
    layoutSize.width = ceil(layoutSize.width * scale) * (1.0 / scale);
    layoutSize.height = ceil(layoutSize.height * scale) * (1.0 / scale);

    // 获取行数
    NSUInteger numberOfGlyphs = manager.numberOfGlyphs;
    NSInteger numberOfLines = 0;
    NSInteger index = 0;
    NSRange lineRange;
    
    for ( numberOfLines = 0 , index = 0; index < numberOfGlyphs ; numberOfLines ++ ) {
        [manager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
        index = NSMaxRange(lineRange);
    }

    // 确定是否单行布局
    if ( fixesSingleLineSpacing && hasCustomLineSpacing && numberOfLines == 1 ) {
        [layoutText enumerateAttribute:NSParagraphStyleAttributeName inRange:(NSRange){0, self.length} options:NSAttributedStringEnumerationReverse usingBlock:^(NSParagraphStyle *value, NSRange range, BOOL * _Nonnull stop) {
            if ( value == nil ) return;
            NSMutableParagraphStyle *style = [value mutableCopy];
            style.lineSpacing = 0;
            [layoutText removeAttribute:NSParagraphStyleAttributeName range:range];
            [layoutText addAttribute:NSParagraphStyleAttributeName value:style range:range];
        }];
    }
    
    // 恢复`lineBreakMode`
    [layoutText enumerateAttribute:NSParagraphStyleAttributeName inRange:(NSRange){0, self.length} options:NSAttributedStringEnumerationReverse usingBlock:^(NSParagraphStyle *value, NSRange range, BOOL * _Nonnull stop) {
        if ( value == nil ) return;
        NSMutableParagraphStyle *style = [value mutableCopy];
        LWZLineBreakModeNumber *lineBreakModeValue = lineBreakModes[[LWZRangeValueKey valueWithRange:range]];
        if ( lineBreakModeValue != nil ) {
            style.lineBreakMode = [lineBreakModeValue integerValue];
            [layoutText removeAttribute:NSParagraphStyleAttributeName range:range];
            [layoutText addAttribute:NSParagraphStyleAttributeName value:style range:range];
        }
    }];
     
    return [LWZTextContainer.alloc initWithText:layoutText layoutSize:layoutSize numberOfLines:numberOfLines];
}
@end
