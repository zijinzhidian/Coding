//
//  EmojiTabBar.m
//  Coding
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "EmojiTabBar.h"

@interface EmojiTabBar ()

@property(nonatomic, strong)UIScrollView *scrollView;

@property(nonatomic, strong)NSArray *selectedImages;
@property(nonatomic, strong)NSArray *unSelectedImages;
@property(nonatomic, strong)NSMutableArray *tabButtons;     //按钮组
@property(nonatomic, assign)CGFloat buttonWidth;            //按钮宽度
@property(nonatomic, assign)NSInteger numOfTabs;            //按钮数量

@end

@implementation EmojiTabBar

- (instancetype)initWithFrame:(CGRect)frame selectedImages:(NSArray *)selectedIamges unSelectedImages:(NSArray *)unSelectedImages {
    self = [super initWithFrame:frame];
    if (self) {
        [self addLineUp:YES andDown:NO andColor:kColorDDD];
        self.selectedImages = selectedIamges;
        self.unSelectedImages = unSelectedImages;
        self.numOfTabs = selectedIamges.count;
        self.buttonWidth = 60.0;
        self.tabButtons = [[NSMutableArray alloc] init];
        
        [self configScrollView];
        [self configSendButton];
        
        self.selectedIndex = -1;            //用于初次渲染图片
        self.selectedIndex = 0;
    }
    return self;
}

- (void)configScrollView {
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - self.buttonWidth, self.frame.size.height)];
    [self addSubview:self.scrollView];
    for (int i = 0; i < self.numOfTabs; i++) {
        UIButton *button = [self tabButtonWithIndex:i];
        [self.scrollView addSubview:button];
        [self.tabButtons addObject:button];
    }
}

- (void)sendButtonClicked:(UIButton *)sender {
    if (self.sendButtonClickedBlock) {
        self.sendButtonClickedBlock();
    }
}

- (void)configSendButton{
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - self.buttonWidth, 0, self.buttonWidth, CGRectGetHeight(self.frame))];
    [self.sendButton setBackgroundColor:kColorBrandBlue];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
}

- (void)tabButtonClicked:(UIButton *)sender {
    NSInteger index = [self.tabButtons indexOfObject:sender];
    if (index != NSNotFound && index != self.selectedIndex) {
        self.selectedIndex = index;
        if (self.selectedIndexChangedBlock) {
            self.selectedIndexChangedBlock(self);
        }
    }
}

- (UIButton *)tabButtonWithIndex:(NSInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.buttonWidth * index, 0, self.buttonWidth, self.frame.size.height);
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.buttonWidth - 0.5, 0, 0.5, button.frame.size.height)];
    lineView.backgroundColor = kColorDDD;
    [button addSubview:lineView];
    [button addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    if (selectedIndex != _selectedIndex) {
        _selectedIndex = selectedIndex;
        for (int i=0; i<self.numOfTabs; i++) {
            UIButton *tabButton = self.tabButtons[i];
            if (i==selectedIndex) {
                [tabButton setImage:self.selectedImages[i] forState:UIControlStateNormal];
                [tabButton setBackgroundColor:kColorNavBG];
            }else{
                [tabButton setImage:self.unSelectedImages[i] forState:UIControlStateNormal];
                [tabButton setBackgroundColor:[UIColor clearColor]];
            }
        }
    }
}


@end
