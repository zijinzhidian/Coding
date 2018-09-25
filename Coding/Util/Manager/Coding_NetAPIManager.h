//
//  Coding_NetAPIManager.h
//  Coding
//
//  Created by apple on 2018/4/20.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodingNetAPIClient.h"
#import "ProjectCount.h"
#import "Project.h"
#import "Projects.h"
#import "CodeFile.h"
#import "ProjectMember.h"

//校验类型
typedef NS_ENUM(NSUInteger, VerifyType) {
    VerifyTypeUnKnow = 0,
    VerifyTypePassword,
    VerifyTypeTotp
};

@interface Coding_NetAPIManager : NSObject

+ (instancetype)sharedManager;

#pragma mark - Login
//两次验证登陆
- (void)request_Login_With2FA:(NSString *)otpCode andBlock:(void (^)(id data, NSError *error))block;
//普通登陆
- (void)request_Login_WithPath:(NSString *)path Params:(id)params andBlock:(void (^)(id data, NSError *error))block;
//是否需要图形验证码
- (void)request_CaptchaNeededWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block;
//发送激活邮件
- (void)request_SendActivateEmail:(NSString *)email block:(void (^)(id data, NSError *error))block;
//注册
- (void)request_Register_V2_WithParams:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block;
//设置用户名
- (void)request_ActivateBySetGlobal_key:(NSString *)global_key block:(void (^)(id data, NSError *error))block;
//设置密码
- (void)request_SetPasswordToPath:(NSString *)path params:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block;


#pragma mark - 2FA
//根据验证码关闭两步验证
- (void)post_Close2FAGeneratePhoneCode:(NSString *)phone withCaptcha:(NSString *)captcha block:(void (^)(id data, NSError *error))block;
//根据手机号码关闭两步验证
- (void)post_Close2FAWithPhone:(NSString *)phone code:(NSString *)code block:(void (^)(id data, NSError *error))block;
//打开两步验证
- (void)get_is2FAOpenBlock:(void (^)(BOOL data, NSError *error))block;

#pragma mark - UnRead
//获取未读消息的数目
- (void)request_UnReadCountWithBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Project
//获取项目的类型和数目
- (void)request_ProjectsCatergoryAndCounts_WithObj:(ProjectCount *)pCount andBlock:(void (^)(ProjectCount *data, NSError *error))block;
//设置或取消项目常用状态
- (void)request_Project_Pin:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
//获取项目列表数据
- (void)request_Projects_WithObj:(Projects *)projects andBlock:(void (^)(Projects *data, NSError *error))block;
//获取项目详细信息
- (void)request_ProjectDetail_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
//更新项目
- (void)request_UpdateProject_WithObj:(Project *)project andBlock:(void (^)(Project *data, NSError *error))block;
//更新项目图标
- (void)request_UpdateProject_WithObj:(Project *)project icon:(UIImage *)icon andBlock:(void (^)(id data, NSError *error))block progressBlock:(void (^)(CGFloat progressValue))progress;
//删除项目
- (void)request_DeleteProject_WithObj:(Project *)project passCode:(NSString *)passCode type:(VerifyType)type andBlock:(void (^)(Project *data, NSError *error))block;
//归档项目
- (void)request_ArchiveProject_WithObj:(Project *)project passCode:(NSString *)passCode type:(VerifyType)type andBlock:(void (^)(Project *data, NSError *error))block;
//转让项目
- (void)request_TransferProject:(Project *)project toUser:(User *)user passCode:(NSString *)passCode type:(VerifyType)type andBlock:(void (^)(Project *data, NSError *error))block;
//获取项目成员列表
- (void)request_ProjectMembers_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
//编辑成员备注名
- (void)request_EditAliasOfMember:(ProjectMember *)curMember inProject:(Project *)curPro andBlock:(void (^)(id data, NSError *error))block;
//编辑成员项目权限
- (void)request_EditTypeOfMember:(ProjectMember *)curMember inProject:(Project *)curPro andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Git Related
//收藏或取消收藏
- (void)request_StarProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
//关注或取消关注
- (void)request_WatchProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
//Fork
- (void)request_ForkProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;
//获取readme文件数据
- (void)request_ReadMeOfProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Code
//获取标签或分支的代码
- (void)request_CodeBranchOrTagWithPath:(NSString *)path withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Other
//获取校验类型
- (void)request_VerifyTypeWithBlock:(void (^)(VerifyType type, NSError *error))block;

@end
