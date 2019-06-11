//
//  UIMessageInputView_Voice.h
//  Coding
//
//  Created by apple on 2019/5/15.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIMessageInputView_Voice : UIView

@property(nonatomic, copy)void(^recordSuccessfully)(NSString *file, NSTimeInterval duration);

@end

NS_ASSUME_NONNULL_END
