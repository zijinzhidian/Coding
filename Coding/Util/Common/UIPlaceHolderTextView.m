//
//  UIPlaceHolderTextView.m
//  Coding
//
//  Created by apple on 2018/8/18.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "UIPlaceHolderTextView.h"

@interface UIPlaceHolderTextView ()
@property(nonatomic,strong)UILabel *placeholderLabel;
@end

@implementation UIPlaceHolderTextView

#pragma mark - Init
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.placeholder = @"";
    self.placeholderColor = [UIColor lightGrayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.placeholder = @"";
        self.placeholderColor = [UIColor lightGrayColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (self.placeholder.length > 0) {
        UIEdgeInsets insets = self.textContainerInset;
        if (_placeholderLabel == nil) {
            _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(insets.left + 5, insets.top, self.bounds.size.width - insets.left - insets.right - 10, 1)];
            _placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeholderLabel.font = self.font;
            _placeholderLabel.backgroundColor = [UIColor clearColor];
            _placeholderLabel.textColor = self.placeholderColor;
            _placeholderLabel.alpha = 0;
            _placeholderLabel.tag = 999;
            [self addSubview:_placeholderLabel];
        }
        _placeholderLabel.text = self.placeholder;
        [_placeholderLabel sizeToFit];          //文本根据文字自适应
        _placeholderLabel.frame = CGRectMake(insets.left + 5, insets.top, self.bounds.size.width - insets.left - insets.right - 10, CGRectGetHeight(_placeholderLabel.frame));            //重新设置文本的高度
    }
    
    if (self.text.length == 0 && self.placeholder.length > 0) {
        [self viewWithTag:999].alpha = 1;
    }
    [super drawRect:rect];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

#pragma mark - Notification Actions
- (void)textChanged:(NSNotification *)notification {
    if (self.placeholder.length == 0) return;
    [UIView animateWithDuration:0.25 animations:^{
        if (self.text.length == 0) {
            [[self viewWithTag:999] setAlpha:1];
        } else {
            [[self viewWithTag:999] setAlpha:0];
        }
    }];
}

#pragma mark - Getters And Setters
- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

@end
