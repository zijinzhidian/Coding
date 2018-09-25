//
//  EaseLoadingView.h
//  Coding
//
//  Created by apple on 2018/5/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EaseLoadingView : UIView
@property(nonatomic,strong)UIImageView *monkeyView;
@property(nonatomic,assign,readonly)BOOL isLoading;
- (void)startAnimating;
- (void)stopAnimating;
@end
