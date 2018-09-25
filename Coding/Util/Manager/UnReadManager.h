//
//  UnReadManager.h
//  Coding
//
//  Created by apple on 2018/5/9.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnReadManager : NSObject

//依次:消息数目、通知信息数目、项目更新数目
@property(nonatomic,strong)NSNumber *messages, *notifications, *project_update_count;

+ (instancetype)shareManager;
- (void)updateUnRead;

@end
