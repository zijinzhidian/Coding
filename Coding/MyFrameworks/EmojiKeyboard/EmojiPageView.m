//
//  EmojiPageView.m
//  Coding
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "EmojiPageView.h"

#define BACKSPACE_BUTTON_TAG 10
#define BUTTON_FONT_SIZE 32

@interface EmojiPageView ()

@property(nonatomic, assign)CGSize buttonSize;
@property(nonatomic, strong)NSMutableArray *buttons;
@property(nonatomic, assign)NSUInteger rows;
@property(nonatomic, assign)NSUInteger columns;
@property(nonatomic, strong)UIImage *backSpaceButtonImage;

@end

@implementation EmojiPageView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame backSpaceButtonImage:(UIImage *)backSpaceButtonImage buttonSize:(CGSize)buttonSize rows:(NSUInteger)rows columns:(NSUInteger)columns {
    self = [super initWithFrame:frame];
    if (self) {
        self.backSpaceButtonImage = backSpaceButtonImage;
        self.buttonSize = buttonSize;
        self.columns = columns;
        self.rows = rows;
        self.buttons = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Public Methods
- (void)setButtonTexts:(NSMutableArray *)buttonTexts forCategory:(NSString *)category {
    if ([category hasPrefix:@"big_"]) {
        if (self.buttons.count - 1 == buttonTexts.count) {
            for (int i = 0; i < buttonTexts.count; i++) {
                [self.buttons[i] setTitle:buttonTexts[i] forState:UIControlStateNormal];
                CGFloat imageHeight = CGRectGetHeight([self.buttons[i] frame]) - 20;
                [self.buttons[i] setImage:[[UIImage imageNamed:buttonTexts[i]] scaledToSize:CGSizeMake(imageHeight, imageHeight) highQuality:YES] forState:UIControlStateNormal];
            }
        } else {
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            self.buttons = nil;
            self.buttons = [NSMutableArray arrayWithCapacity:self.rows * self.columns];
            for (NSUInteger i = 0; i < buttonTexts.count; i++) {
                UIButton *button = [self createButtonAtIndex:i];
                [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                [button setTitle:buttonTexts[i] forState:UIControlStateNormal];
                CGFloat buttonWidth = CGRectGetWidth(button.frame);
                CGFloat imageHeight = CGRectGetHeight(button.frame) - 20;
                [button setImageEdgeInsets:UIEdgeInsetsMake(10, (buttonWidth - imageHeight)/2, 10, (buttonWidth - imageHeight)/2)];
                [button setImage:[[UIImage imageNamed:buttonTexts[i]] scaledToSize:CGSizeMake(imageHeight, imageHeight) highQuality:YES] forState:UIControlStateNormal];
                [self addToViewButton:button];
            }
        }
    } else {
        if (([self.buttons count] - 1) == [buttonTexts count]) {
            // just reset text on each button
            for (NSUInteger i = 0; i < [buttonTexts count]; ++i) {
                [self.buttons[i] setTitle:buttonTexts[i] forState:UIControlStateNormal];
            }
        } else {
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            self.buttons = nil;
            self.buttons = [NSMutableArray arrayWithCapacity:self.rows * self.columns];
            for (NSUInteger i = 0; i < [buttonTexts count]; ++i) {
                UIButton *button = [self createButtonAtIndex:i];
                [button setTitle:buttonTexts[i] forState:UIControlStateNormal];
                [self addToViewButton:button];
            }
            UIButton *button = [self createButtonAtIndex:self.rows * self.columns - 1];
            [button setImage:self.backSpaceButtonImage forState:UIControlStateNormal];
            button.tag = BACKSPACE_BUTTON_TAG;
            [self addToViewButton:button];
        }
    }
}

#pragma mark - Button Methods
- (void)emojiButtonPressed:(UIButton *)button {
    if (button.tag == BACKSPACE_BUTTON_TAG) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(emojiPageViewDidPressBackSpace:)]) {
            [self.delegate emojiPageViewDidPressBackSpace:self];
        }
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiPageView:didUseEmoji:)]) {
        [self.delegate emojiPageView:self didUseEmoji:button.titleLabel.text];
    }
}

#pragma mark - Private Methods
- (UIButton *)createButtonAtIndex:(NSUInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont fontWithName:@"Apple color emoji" size:BUTTON_FONT_SIZE];
    NSInteger row = (NSInteger)(index / self.columns);
    NSInteger column = (NSInteger)(index % self.columns);
    button.frame = CGRectIntegral(CGRectMake([self XMarginForButtonInColumn:column],
                                             [self YMarginForButtonInRow:row],
                                             self.buttonSize.width,
                                             self.buttonSize.height));
    [button addTarget:self action:@selector(emojiButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}


- (CGFloat)XMarginForButtonInColumn:(NSInteger)column {
    CGFloat padding = ((CGRectGetWidth(self.bounds) - self.columns * self.buttonSize.width) / self.columns);
    return (padding / 2 + column * (padding + self.buttonSize.width));
}

- (CGFloat)YMarginForButtonInRow:(NSInteger)rowNumber {
    CGFloat padding = ((CGRectGetHeight(self.bounds) - self.rows * self.buttonSize.height) / self.rows);
    return (padding / 2 + rowNumber * (padding + self.buttonSize.height));
}

- (void)addToViewButton:(UIButton *)button {
    
    NSAssert(button != nil, @"Button to be added is nil");
    
    [self.buttons addObject:button];
    [self addSubview:button];
}

@end
