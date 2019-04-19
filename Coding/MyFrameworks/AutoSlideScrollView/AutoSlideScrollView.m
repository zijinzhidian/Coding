//
//  AutoSlideScrollView.m
//  Coding
//
//  Created by apple on 2019/3/15.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "AutoSlideScrollView.h"

@interface AutoSlideScrollView ()

@property(nonatomic, strong)UIScrollView *scrollView;

@end

@implementation AutoSlideScrollView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame anitmationDuration:(NSTimeInterval)animationDutation {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.scrollView];
    }
    return self;
}

#pragma mark - Getters And Setters
- (void)setTotalPagesCount:(NSInteger (^)(void))totalPagesCount {
    self.totalPagesCount = totalPagesCount;
}

- (void)setFetchContentViewAtIndex:(UIView * _Nonnull (^)(NSInteger))fetchContentViewAtIndex {
    self.fetchContentViewAtIndex = fetchContentViewAtIndex;
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    self.currentPageIndex = currentPageIndex;
    if (self.currentPageIndexChangeBlock) {
        self.currentPageIndexChangeBlock(currentPageIndex);
    }
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.contentMode = UIViewContentModeCenter;
        _scrollView.backgroundColor = [UIColor redColor];
    }
    return _scrollView;
}

@end
