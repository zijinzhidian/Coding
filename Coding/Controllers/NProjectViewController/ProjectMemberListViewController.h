//
//  ProjectMemberListViewController.h
//  Coding
//
//  Created by apple on 2018/8/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "BaseViewController.h"
#import "ProjectMember.h"

typedef NS_ENUM(NSInteger, ProMemType) {
    ProMemTypeProject = 0,          //可编辑的项目
    ProMemTypeTaskOwner,            //管理任务拥有者
    ProMemTypeAT,                   //@某个成员
    ProMemTypeTaskWatchers,
    ProMemTypeTopicWatchers
};
typedef void(^ProjectMemberBlock)(ProjectMember *member);           //选中成员后的回调
typedef void(^ProjectMemberListBlock)(NSArray *memberArray);        //刷新成员列表的回调
typedef void(^ProjectMemberCellBtnBlock)(ProjectMember *member);    //cell上按钮点击的回调

@interface ProjectMemberListViewController : BaseViewController

@property(nonatomic,strong)NSMutableArray *myMemberArray;   //成员列表数组


/**
 初始化数据

 @param frame 控制器视图frame
 @param project 项目对象
 @param type 类型
 @param refreshBlock 刷新成员类别的回调
 @param selectBlock 选中成员列表的回调
 @param cellBtnBlock cell上按钮点击的回调
 */
- (void)setFrame:(CGRect)frame project:(Project *)project type:(ProMemType)type refreshBlock:(ProjectMemberListBlock)refreshBlock selectBlock:(ProjectMemberBlock)selectBlock cellBtnBlock:(ProjectMemberCellBtnBlock)cellBtnBlock;

@end
