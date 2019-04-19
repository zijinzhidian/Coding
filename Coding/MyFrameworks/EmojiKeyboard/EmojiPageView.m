//
//  EmojiPageView.m
//  Coding
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "EmojiPageView.h"

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
        self.backgroundColor = [UIColor randomColor];
    }
    return self;
}

- (void)setButtonTexts:(NSMutableArray *)buttonTexts forCategory:(NSString *)category {
    if ([category hasPrefix:@"big_"]) {
        if (self.buttons.count - 1 == buttonTexts.count) {
            for (int i = 0; i < buttonTexts.count; i++) {
                
            }
        } else {
            
        }
    }
}

@end
