//
//  UIPlaceHolderTextView.h
//  Coding
//
//  Created by apple on 2018/8/18.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property(nonatomic,strong)NSString *placeholder;
@property(nonatomic,strong)UIColor *placeholderColor;

- (void)textChanged:(NSNotification *)notification;

@end
