//
//  ValueListViewController.h
//  Coding
//
//  Created by apple on 2018/8/27.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, ValueListType) {
    ValueListTypeTaskStatus = 0,        //任务状态
    ValueListTypeTaskPriority,          //任务优先级
    ValueListTypeProjectMemberType      //项目成员权限
};
typedef void(^IndexSelectedBlock) (NSInteger index);

@interface ValueListViewController : BaseViewController


/**
 设置参数

 @param title 标题
 @param list 列表
 @param index 默认选中下标
 @param type 类型
 @param selectBlock 选中后回调
 */
- (void)setTitle:(NSString *)title valueList:(NSArray *)list defaultSelectIndex:(NSInteger)index type:(ValueListType)type selectBlock:(IndexSelectedBlock)selectBlock;

@end
