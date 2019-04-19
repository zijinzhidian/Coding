//
//  Tweet_RootViewController.h
//  Coding
//
//  Created by apple on 2018/5/8.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, Tweet_RootViewControllerType){
    Tweet_RootViewControllerTypeAll = 0,
    Tweet_RootViewControllerTypeFriend,
    Tweet_RootViewControllerTypeHot,
    Tweet_RootViewControllerTypeMine
};

@interface Tweet_RootViewController : BaseViewController

@end
