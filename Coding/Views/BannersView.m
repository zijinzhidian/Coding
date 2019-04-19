//
//  BannersView.m
//  Coding
//
//  Created by apple on 2019/3/15.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "BannersView.h"
#import "AutoSlideScrollView.h"
#import "YLImageView.h"

@interface BannersView ()

@property(nonatomic, assign)CGFloat paddingTop, paddingBottom, imageWidth, radio;

@property(nonatomic, strong)AutoSlideScrollView *slideScrollView;
@property(nonnull, strong)NSMutableArray *imageViewList;

@end

@implementation BannersView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = kColorTableBG;
        _paddingTop = 0;
        _paddingBottom = 44;
        _imageWidth = kScreen_Width;
        _radio = 0.4;
        CGFloat viewHeight = _paddingTop + _paddingBottom  + _imageWidth * _radio;
        [self setSize:CGSizeMake(kScreen_Width, viewHeight)];
        [self addLineUp:NO andDown:YES];
    }
    return self;
}

- (void)setCurBannerList:(NSArray *)curBannerList {
    if ([[_curBannerList valueForKey:@"title"] isEqualToArray:[curBannerList valueForKey:@"title"]]) {
        return;
    }
    _curBannerList = curBannerList;
    
    [self addSubview:self.slideScrollView];
}

#pragma mark - Getters And Setters
- (AutoSlideScrollView *)slideScrollView {
    if (!_slideScrollView) {
        _slideScrollView = [[AutoSlideScrollView alloc] initWithFrame:CGRectMake(0, _paddingTop, _imageWidth, _imageWidth * _radio) anitmationDuration:3.0];
        __weak typeof(self) weakSelf = self;
        _slideScrollView.totalPagesCount = ^NSInteger{
            return weakSelf.curBannerList.count;
        };
        _slideScrollView.fetchContentViewAtIndex = ^UIView * _Nonnull(NSInteger pageIndex) {
            if (weakSelf.curBannerList.count > pageIndex) {
//                YLImageView *imageView = [YLImageView ];
                return nil;
            } else {
                return [[UIView alloc] init];
            }
        };
    }
    return _slideScrollView;
}

- (YLImageView *)p_reuseViewForIndex:(NSInteger)pageIndex {
    if (!_imageViewList) {
        _imageViewList = [NSMutableArray arrayWithCapacity:3];
        for (int i = 0; i < 3; i++) {
            YLImageView *view = [[YLImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, _paddingTop, _imageWidth, _imageWidth * _radio)];
            view.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
            [_imageViewList addObject:view];
        }
    }
    return nil;
}

@end
