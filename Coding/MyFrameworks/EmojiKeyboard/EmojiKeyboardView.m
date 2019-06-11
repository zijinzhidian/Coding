//
//  EmojiKeyboardView.m
//  Coding
//
//  Created by apple on 2019/3/25.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "EmojiKeyboardView.h"
#import "SMPageControl.h"
#import "EmojiTabBar.h"
#import "EmojiPageView.h"

static NSString *const segmentRecentName = @"Recent";           //最近使用的表情分类名字
static NSString *const RecentUsedEmojiCharactersKey = @"RecentUsedEmojiCharactersKey";  //存储最近使用的表情的key
static CGFloat easeTabBar_Height = 36.0;                        //底部标签栏高度

@interface EmojiKeyboardView ()<UIScrollViewDelegate, EmojiPageViewDelegate>

@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)SMPageControl *pageControl;
@property(nonatomic, strong)EmojiTabBar *tabBar;

@property(nonatomic, strong)NSMutableArray *pageViews;

@property(nonatomic, copy)NSString *category;
@property(nonatomic, strong)NSDictionary *emojis;

@end

@implementation EmojiKeyboardView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(id<EmojiKeyboardDataSource>) dataSource
               showBigEmotion:(BOOL)showBigEmotion {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kColorNavBG;
        
        self.dataSource = dataSource;
        self.category = [self categoryNameAtIndex:self.defaultSelectCategory];
        
        __weak typeof(self) weakSelf = self;
        CGFloat selfHeight = CGRectGetHeight(self.bounds);
        if (!showBigEmotion) {
            self.tabBar = [[EmojiTabBar alloc] initWithFrame:CGRectMake(0, selfHeight - easeTabBar_Height, self.bounds.size.width, easeTabBar_Height)
                                              selectedImages:[self.imagesForSelectedSegments objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]]
                                            unSelectedImages:[self.imagesForNonSelectedSegments objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]]];
        } else {
            self.tabBar = [[EmojiTabBar alloc] initWithFrame:CGRectMake(0, selfHeight - easeTabBar_Height, self.bounds.size.width, easeTabBar_Height) selectedImages:self.imagesForSelectedSegments unSelectedImages:self.imagesForNonSelectedSegments];
        }
        self.tabBar.selectedIndexChangedBlock = ^(EmojiTabBar * _Nonnull tabBar) {
            [weakSelf categoryChangeViaSegmentsBar:tabBar];
        };
        self.tabBar.sendButtonClickedBlock = ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(emojiKeyboardViewDidPressSendButton:)]) {
                [weakSelf.delegate emojiKeyboardViewDidPressSendButton:weakSelf];
            }
        };
        self.tabBar.selectedIndex = self.defaultSelectCategory;
        [self addSubview:self.tabBar];
        
        self.pageControl = [[SMPageControl alloc] init];
        self.pageControl.pageIndicatorImage = [UIImage imageNamed:@"keyboard_page_unselected"];
        self.pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"keyboard_page_selected"];
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.backgroundColor = [UIColor clearColor];
        //页数
        NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category];
        self.pageControl.numberOfPages = numberOfPages;
        //控件尺寸
        CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
        self.pageControl.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                                           CGRectGetHeight(self.bounds) - easeTabBar_Height - pageControlSize.height - 10,
                                                           pageControlSize.width,
                                                           pageControlSize.height));
        self.pageControl.currentPage = 0;
        [self addSubview:self.pageControl];
        
        
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - easeTabBar_Height - pageControlSize.height - 20)];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.backgroundColor = [UIColor redColor];
        self.scrollView.delegate = self;
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * numberOfPages, CGRectGetHeight(self.scrollView.bounds));
        [self addSubview:self.scrollView];
        
        [self setPage:self.pageControl.currentPage];
        
    }
    return self;
}

- (void)layoutSubviews {
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
    NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category];
    
    NSInteger currentPage = (self.pageControl.currentPage > numberOfPages) ? numberOfPages : self.pageControl.currentPage;
    
    // if (currentPage > numberOfPages) it is set implicitly to max pageNumber available
    self.pageControl.numberOfPages = numberOfPages;
    pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
    self.pageControl.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                                       CGRectGetHeight(self.bounds) - CGRectGetHeight(self.tabBar.bounds) - pageControlSize.height - 10.0,
                                                       pageControlSize.width,
                                                       pageControlSize.height));
    
    self.scrollView.frame = CGRectMake(0,
                                       0,
                                       CGRectGetWidth(self.bounds),
                                       CGRectGetHeight(self.bounds) - CGRectGetHeight(self.tabBar.bounds) - pageControlSize.height- 20.0);
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds) * currentPage, 0);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * numberOfPages, CGRectGetHeight(self.scrollView.bounds));
    [self purgePageViews];
    self.pageViews = [NSMutableArray array];
    [self setPage:currentPage];
}

#pragma mark - Data Source
//表情列表
- (NSDictionary *)emojis {
    if (!_emojis) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emotion_list" ofType:@"plist"];
        _emojis = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return _emojis;
}

//默认表情分类
- (EmojiKeyboardViewCategoryImage)defaultSelectCategory {
    if ([self.dataSource respondsToSelector:@selector(defaultCategoryForEmojiKeyboardView:)]) {
        return [self.dataSource defaultCategoryForEmojiKeyboardView:self];
    }
    return EmojiKeyboardViewCategoryImageEmoji;
}

//表情分类名字
- (NSString *)categoryNameAtIndex:(NSUInteger)index {
    NSArray *categoryList = @[@"emoji", @"emoji_code", @"big_monkey", @"big_monkey_gif"];
    return index < categoryList.count ? categoryList[index] : categoryList.lastObject;
}

//每页表情分类列表
- (NSArray *)emojiListForCategory:(NSString *)category {
    if ([category isEqualToString:segmentRecentName]) {
        return [self recentEmojis];
    }
    return [self.emojis objectForKey:category];
}

//最近使用过的表情分类列表
- (NSMutableArray *)recentEmojis {
    NSArray *emogis = [[NSUserDefaults standardUserDefaults] arrayForKey:RecentUsedEmojiCharactersKey];
    NSMutableArray *recentEmojis = [emogis copy];
    if (recentEmojis == nil) {
        recentEmojis = [NSMutableArray array];
    }
    return recentEmojis;
}

//页数
- (NSInteger)numberOfPagesForCategory:(NSString *)category {
    //最近使用的表情
    if ([category isEqualToString:segmentRecentName]) {
        return 1;
    }
    //表情分类个数
    NSUInteger emojiCount = [[self emojiListForCategory:category] count];
    //行数
    NSUInteger numberOfRows = [self numberOfRows];
    //列数
    NSUInteger numberOfColumns = [self numberOfColumns];
    
    //一页的表情个数(不是大表情的界面有个'删除键',需减1)
    NSUInteger numberOfEmojisOnAPage;
    if ([category hasPrefix:@"big_"]) {
        numberOfEmojisOnAPage = numberOfRows * numberOfColumns;
    } else {
        numberOfEmojisOnAPage = numberOfRows * numberOfColumns - 1;
    }
    //页数
    NSUInteger numberOfPages = (NSUInteger)ceil((float)emojiCount / numberOfEmojisOnAPage);
    return numberOfPages;
}

//行数
- (NSUInteger)numberOfRows {
    NSInteger rows;
    if ([self.category hasPrefix:@"big_"]) {
        rows = 2;
    } else {
        rows = 3;
    }
    return rows;
}

//列数
- (NSUInteger)numberOfColumns {
    NSInteger columns;
    if ([self.category hasPrefix:@"big_"]) {
        columns = 4;
    } else {
        columns = 7;
    }
    return columns;
}

//tabBar按钮选中图片组
- (NSArray *)imagesForSelectedSegments {
    static NSMutableArray *array;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [NSMutableArray array];
        for (int i = 0; i < self.emojis.allKeys.count; i++) {
            [array addObject:[self.dataSource emojiKeyboardView:self imageForSelectedCategory:i]];
        }
    });
    return array;
}

//tabBar按钮未选中图片组
- (NSArray *)imagesForNonSelectedSegments {
    static NSMutableArray *array;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [NSMutableArray array];
        for (int i = 0; i < self.emojis.allKeys.count; i++) {
            [array addObject:[self.dataSource emojiKeyboardView:self imageForNonSelectedCategory:i]];
        }
    });
    return array;
}

//根据开始和结束索引返回类别的表情符号
- (NSMutableArray *)emojiTextsForCategory:(NSString *)category fromIndex:(NSUInteger)start toIndex:(NSUInteger)end {
    NSArray *emojis = [self emojiListForCategory:category];
    end = emojis.count > end ? end : emojis.count;
    NSIndexSet *index = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(start, end - start)];
    return [[emojis objectsAtIndexes:index] mutableCopy];
}

#pragma mark - Change a page on scrollView
/**
 初始化pageView
 */
- (EmojiPageView *)synthesizeEmojiPageView {
    CGSize frameSize = self.scrollView.bounds.size;
    CGFloat btnWidth, btnHeight;
    if ([self.category hasPrefix:@"big_"]) {
        btnWidth = floor(frameSize.width / 4.0);
        btnHeight = floor(frameSize.height / 2.0);
    } else {
        btnWidth = floor(frameSize.width / 7.0);
        btnHeight = floor(frameSize.height / 3.0);
    }
    
    NSUInteger rows = [self numberOfRows];
    NSUInteger columns = [self numberOfColumns];
    
    EmojiPageView *pageView = [[EmojiPageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds),CGRectGetHeight(self.scrollView.bounds))
                                              backSpaceButtonImage:[self.dataSource backSpaceButtonImageForEmojiKeyboardView:self]
                                                        buttonSize:CGSizeMake(btnWidth, btnHeight)
                                                              rows:rows
                                                           columns:columns];
    pageView.delegate = self;
    [self.pageViews addObject:pageView];
    [self.scrollView addSubview:pageView];
    return pageView;
}

//设置pageView
- (void)setEmojiPageViewInScrollView:(UIScrollView *)scrollView atIndex:(NSUInteger)index {
    //判断是否需要设置pageView
    if (![self requireToSetPageViewForIndex:index]) {
        return;
    }
    
    EmojiPageView *pageView = [self usableEmojiPageView];
    
    NSUInteger rows = [self numberOfRows];
    NSUInteger columns = [self numberOfColumns];
    NSInteger numberOfEmojisOnAPage;
    if ([self.category hasPrefix:@"big_"]) {
        numberOfEmojisOnAPage = rows * columns;
    } else {
        numberOfEmojisOnAPage = rows * columns - 1;
    }
    NSUInteger startingIndex = index * numberOfEmojisOnAPage;
    NSUInteger endingIndex = (index + 1) * numberOfEmojisOnAPage;
    NSMutableArray *buttonTexts = [self emojiTextsForCategory:self.category fromIndex:startingIndex toIndex:endingIndex];
    [pageView setButtonTexts:buttonTexts forCategory:self.category];
    
    pageView.frame = CGRectMake(index * CGRectGetWidth(scrollView.bounds), 0, CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds));
    
}

//是否需要设置pageView
- (BOOL)requireToSetPageViewForIndex:(NSUInteger)index {
    //防止index越界(由于index为NSUInteger类型,所以当index为负数时,也会执行并return NO)
    if (index >= self.pageControl.numberOfPages) {
        return NO;
    }
    
    //如果pageView已经存在于数组里面,则不需要重新设置
    for (EmojiPageView *pageView in self.pageViews) {
        if (pageView.frame.origin.x / CGRectGetWidth(self.scrollView.bounds) == index) {
            return NO;
        }
    }
    return YES;
}


//获取可用的pageView
- (EmojiPageView *)usableEmojiPageView {
    EmojiPageView *pageView = nil;
    //若pageView存在于数组,则从数组里取
    for (EmojiPageView *page in self.pageViews) {
        NSUInteger pageNumber = page.frame.origin.x / self.scrollView.bounds.size.width;
        if (abs((int)(pageNumber - self.pageControl.currentPage)) > 1) {
            pageView = page;
            break;
        }
    }
    
    //若不存在则创建
    if (!pageView) {
        pageView = [self synthesizeEmojiPageView];
    }
    return pageView;
}

- (void)setPage:(NSInteger)page {
    [self setEmojiPageViewInScrollView:self.scrollView atIndex:page - 1];
    [self setEmojiPageViewInScrollView:self.scrollView atIndex:page];
    [self setEmojiPageViewInScrollView:self.scrollView atIndex:page + 1];
}

- (void)purgePageViews {
    for (EmojiPageView *page in self.pageViews) {
        page.delegate = nil;
    }
    self.pageViews = nil;
}

#pragma mark - Public Methods
- (void)setDoneButtonTitle:(NSString *)doneStr {
    [self.tabBar.sendButton setTitle:doneStr forState:UIControlStateNormal];
}

#pragma mark - Private Methods
- (void)categoryChangeViaSegmentsBar:(EmojiTabBar *)sender {
    self.category = [self categoryNameAtIndex:sender.selectedIndex];
    self.pageControl.currentPage = 0;
    [self setNeedsLayout];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.pageControl.currentPage == newPageNumber) {
        return;
    }
    self.pageControl.currentPage = newPageNumber;
    [self setPage:self.pageControl.currentPage];
}

#pragma mark - EmojiPageViewDelegate
- (void)emojiPageView:(EmojiPageView *)emojiPageView didUseEmoji:(NSString *)emoji {
    NSAssert(emoji != nil, @"Emoji can't be nil");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiKeyboardView:didUseEmoji:)]) {
        [self.delegate emojiKeyboardView:self didUseEmoji:emoji];
    }
}

- (void)emojiPageViewDidPressBackSpace:(EmojiPageView *)emojiPageView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiKeyboardViewDidPressBackSpace:)]) {
        [self.delegate emojiKeyboardViewDidPressBackSpace:self];
    }
}



@end
