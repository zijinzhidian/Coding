//
//  Coding_NetAPIManager.m
//  Coding
//
//  Created by apple on 2018/4/20.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "Coding_NetAPIManager.h"
#import "Login.h"
#import "CodeBranchOrTag.h"

@implementation Coding_NetAPIManager
+ (instancetype)sharedManager {
    static Coding_NetAPIManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma mark - Login
- (void)request_Login_With2FA:(NSString *)otpCode andBlock:(void (^)(id data, NSError *error))block {
    
    if (otpCode.length <= 0) {
        return;
    }
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/check_two_factor_auth_code" withParams:@{@"code": otpCode} withMethodType:Post andBlock:^(id data, NSError *error) {
        
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        } else {
            block(nil, error);
        }
    }];
    
}

- (void)request_Login_WithPath:(NSString *)path Params:(id)params andBlock:(void (^)(id data, NSError *error))block {
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            //检查当前帐号是否激活
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/unread-count" withParams:nil withMethodType:Get autoShowError:NO andBlock:^(id data_check, NSError *error_check) {
                if (error_check.userInfo[@"msg"][@"user_need_activate"]) {
                    block(nil, error_check);
                } else {
                    User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
                    if (curLoginUser) {
                        [Login doLogin:resultData];
                    }
                    block(curLoginUser, nil);
                }
            }];
        } else {
            block(nil, error);
        }
        
    }];
}

- (void)request_CaptchaNeededWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block {
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        } else {
            block(nil,error);
        }
        
    }];
}

- (void)request_SendActivateEmail:(NSString *)email block:(void (^)(id data, NSError *error))block {
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/register/email/send" withParams:@{@"email": email} withMethodType:Post andBlock:^(id data, NSError *error) {
        
        if (data) {
            if ([(NSNumber *)data[@"data"] boolValue]) {
                block(data, nil);
            } else {
                [NSObject showHudTipStr:@"发送失败"];
                block(nil, nil);
            }
        } else {
            block(nil, error);
        }
        
    }];
}

- (void)request_Register_V2_WithParams:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block {
    NSString *path = @"api/v2/account/register";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_ActivateBySetGlobal_key:(NSString *)global_key block:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/account/global_key/acitvate";
    NSDictionary *params = @{@"global_key": global_key};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_SetPasswordToPath:(NSString *)path params:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block {
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark - 2FA
- (void)post_Close2FAGeneratePhoneCode:(NSString *)phone withCaptcha:(NSString *)captcha block:(void (^)(id data, NSError *error))block{
    NSMutableDictionary *params = @{@"phone": phone, @"from": @"mart"}.mutableCopy;
    if (captcha.length > 0) {
        params[@"j_captcha"] = captcha;
    }
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/twofa/close/code" withParams:params withMethodType:Post autoShowError:captcha.length > 0 andBlock:^(id data, NSError *error) {
        if (captcha.length <= 0 && error && error.userInfo[@"msg"] && ![[error.userInfo[@"msg"] allKeys] containsObject:@"j_captcha_error"]) {
            [NSObject showError:error];
        }
        block(data, error);
    }];
}

- (void)post_Close2FAWithPhone:(NSString *)phone code:(NSString *)code block:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/twofa/close" withParams:@{@"phone": phone, @"code": code} withMethodType:Post andBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}

- (void)get_is2FAOpenBlock:(void (^)(BOOL data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/2fa/method" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        block([data[@"data"] isEqualToString:@"totp"], error);
    }];
}

#pragma mark - UnRead
- (void)request_UnReadCountWithBlock:(void (^)(id data, NSError *error))block {
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/unread-count" withParams:nil withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        } else {
            block(nil, error);
        }
    }];
}

#pragma mark - Project
- (void)request_ProjectsCatergoryAndCounts_WithObj:(ProjectCount *)pCount andBlock:(void (^)(ProjectCount *data, NSError *error))block {
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/project_count" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            ProjectCount *prosC = [NSObject objectOfClass:@"ProjectCount" fromJSON:resultData];
            block(prosC, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Project_Pin:(Project *)project andBlock:(void (^)(id data, NSError *error))block {
    NSDictionary *params = @{@"ids": project.id.stringValue};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/projects/pin" withParams:params withMethodType:project.pin.boolValue ? Delete : Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        } else {
            block(nil, error);
        }
    }];
}

- (void)request_Projects_WithObj:(Projects *)projects andBlock:(void (^)(Projects *data, NSError *error))block {
    projects.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[projects toPath] withParams:[projects toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        projects.isLoading = NO;
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Projects *pros = [NSObject objectOfClass:@"Projects" fromJSON:resultData];
            block(pros, nil);
        } else {
            block(nil,error);
        }
    }];
}


- (void)request_ProjectDetail_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block {
    project.isLoadingDetail = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toDetailPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        project.isLoadingDetail = NO;
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Project *resultA = [NSObject objectOfClass:@"Project" fromJSON:resultData];
            block(resultA, nil);
        } else {
            block(nil, error);
        }
    }];
}

#pragma mark - Git Related
- (void)request_StarProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/%@", project.owner_user_name, project.name, project.stared.boolValue? @"unstar": @"star"];
    project.isStaring = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        project.isStaring = NO;
        if (data) {
            project.stared = [NSNumber numberWithBool:!project.stared.boolValue];
            project.star_count = [NSNumber numberWithInteger:project.star_count.integerValue + (project.stared.boolValue? 1: -1)];
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}


- (void)request_WatchProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/%@", project.owner_user_name, project.name, project.watched.boolValue? @"unwatch": @"watch"];
    project.isWatching = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        project.isWatching = NO;
        if (data) {
            project.watched = [NSNumber numberWithBool:!project.watched.boolValue];
            project.watch_count = [NSNumber numberWithInteger:project.watch_count.integerValue + (project.watched.boolValue? 1: -1)];
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}


- (void)request_ForkProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/git/fork", project.owner_user_name, project.name];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = @"正在Fork项目";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        //此处得到的data是一个GitProject,需要在请求一次Project的详细信息
        if (data) {
            project.forked = [NSNumber numberWithBool:!project.forked.boolValue];
            project.fork_count = [NSNumber numberWithInteger:project.fork_count.integerValue + 1];
            Project *forkedPro = [[Project alloc] init];
            forkedPro.owner_user_name = [Login curLoginUser].global_key;
            forkedPro.name = project.name;
            [[Coding_NetAPIManager sharedManager] request_ProjectDetail_WithObj:forkedPro andBlock:^(id data, NSError *error) {
                [hud hideAnimated:YES];
                if (data) {
                    block(data, nil);
                } else {
                    block(nil, error);
                }
            }];
        } else {
            [hud hideAnimated:YES];
            block(nil, error);
        }
    }];
}

- (void)request_ReadMeOfProject:(Project *)project andBlock:(void (^)(id data, NSError *error))block {
    [[Coding_NetAPIManager sharedManager] request_CodeBranchOrTagWithPath:@"list_branches" withPro:project andBlock:^(id dataTemp, NSError *errorTemp) {
        if (dataTemp) {
            NSArray *branchList = (NSArray *)dataTemp;
            if (branchList.count > 0) {
                __block NSString *defaultBranch = @"master";
                [branchList enumerateObjectsUsingBlock:^(CodeBranchOrTag *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.is_default_branch.boolValue) {
                        defaultBranch = obj.name;
                    }
                }];
                
                NSString *path = [NSString stringWithFormat:@"api/user/%@/project/%@/git/tree/%@",project.owner_user_name, project.name, defaultBranch];
                [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
                    if (data) {
                        id resultData = data[@"data"][@"readme"];
                        if (resultData) {
                            CodeFile *rCodeFile = [NSObject objectOfClass:@"CodeFile" fromJSON:data[@"data"]];
                            CodeFile_RealFile *realFile = [NSObject objectOfClass:@"CodeFile_RealFile" fromJSON:resultData];
                            rCodeFile.path = realFile.path;
                            rCodeFile.file = realFile;
                            block(rCodeFile, nil);
                        } else {
                              block(@"我们推荐每个项目都新建一个README文件（客户端暂时不支持创建和编辑README）", nil);
                        }
                    } else {
                        block(nil, error);
                    }
                }];
            } else {        //无readme文件
                block(@"我们推荐每个项目都新建一个README文件（客户端暂时不支持创建和编辑README）", nil);
            }
        } else {    //加载失败
            block(@"加载失败...", errorTemp);
        }
        
    }];
}

-(void)request_UpdateProject_WithObj:(Project *)project andBlock:(void (^)(Project *data, NSError *error))block {
    [NSObject showStatusBarQueryStr:@"正在更新项目"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toUpdatePath] withParams:[project toUpdateParams] withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showStatusBarSuccessStr:@"更新项目成功"];
            id resltData = [data valueForKeyPath:@"data"];
            Project *resultA = [NSObject objectOfClass:@"Project" fromJSON:resltData];
            block(resultA, nil);
        } else {
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}

- (void)request_UpdateProject_WithObj:(Project *)project icon:(UIImage *)icon andBlock:(void (^)(id data, NSError *error))block progressBlock:(void (^)(CGFloat progressValue))progress {
    [[CodingNetAPIClient sharedJsonClient] uploadImage:icon path:[project toUpdateIconPath] name:@"file" successBlock:^(NSURLSessionDataTask *task, id responseObject) {
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        } else {
            block(responseObject, nil);
            [NSObject showStatusBarSuccessStr:@"更新项目图标成功"];
        }
    } failureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        block(nil, error);
        [NSObject showStatusBarError:error];
    } progressBlock:progress];
}

- (void)request_DeleteProject_WithObj:(Project *)project passCode:(NSString *)passCode type:(VerifyType)type andBlock:(void (^)(Project *data, NSError *error))block {
    if (!project.name || !passCode) {
        return;
    }
    NSDictionary *params;
    if (type == VerifyTypePassword) {
        params = @{
                   @"name": project.name,
                   @"two_factor_code": [passCode sha1Str]
                   };
    }else if (type == VerifyTypeTotp){
        params = @{
                   @"name": project.name,
                   @"two_factor_code": passCode
                   };
    }else{
        return;
    }
    [NSObject showStatusBarQueryStr:@"正在删除项目"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toDeletePath] withParams:params withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showStatusBarSuccessStr:@"删除项目成功"];
            block(data, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}

- (void)request_ArchiveProject_WithObj:(Project *)project passCode:(NSString *)passCode type:(VerifyType)type andBlock:(void (^)(Project *data, NSError *error))block{
    NSDictionary *params = @{@"two_factor_code": (type == VerifyTypePassword? [passCode sha1Str]: passCode)};;
    [NSObject showStatusBarQueryStr:@"正在归档项目"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toArchivePath] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showStatusBarSuccessStr:@"归档项目成功"];
            block(data, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}

- (void)request_TransferProject:(Project *)project toUser:(User *)user passCode:(NSString *)passCode type:(VerifyType)type andBlock:(void (^)(Project *data, NSError *error))block{
    if (project.id.stringValue.length <= 0 || user.global_key.length <= 0|| passCode.length <= 0) {
        return;
    }
    NSString *path = [NSString stringWithFormat:@"api/project/%@/transfer_to/%@", project.id.stringValue, user.global_key];
    NSDictionary *params;
    if (type == VerifyTypePassword) {
        params = @{@"two_factor_code": [passCode sha1Str]};
    }else if (type == VerifyTypeTotp){
        params = @{@"two_factor_code": passCode};
    }else{
        return;
    }
    [NSObject showStatusBarQueryStr:@"正在转让项目"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showStatusBarSuccessStr:@"转让项目成功"];
            block(data, nil);
        }else{
            [NSObject showStatusBarError:error];
            block(nil, error);
        }
    }];
}

- (void)request_ProjectMembers_WithObj:(Project *)project andBlock:(void (^)(id data, NSError *error))block {
    project.isLoadingMember = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toMembersPath] withParams:[project toMembersParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        project.isLoadingMember = NO;
        if (data) {
            id resultData = [data valueForKey:@"data"];
            if (resultData) {  //存储到本地
                [NSObject saveResponseData:resultData toPath:[project localMembersPath]];
            }
            resultData = [resultData objectForKey:@"list"];
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectMember"];
            block(resultA, nil);
        } else {
            block(nil, error);
        }
    }];
}

- (void)request_EditAliasOfMember:(ProjectMember *)curMember inProject:(Project *)curPro andBlock:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"api/project/%@/members/update_alias/%@", curPro.id, curMember.user_id];
    NSDictionary *params = @{@"alias": curMember.editAlias};
    [NSObject showStatusBarQueryStr:@"正在设置备注"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showStatusBarSuccessStr:@"备注设置成功"];
        } else {
            [NSObject showStatusBarError:error];
        }
        block(data, error);
    }];
}

- (void)request_EditTypeOfMember:(ProjectMember *)curMember inProject:(Project *)curPro andBlock:(void (^)(id data, NSError *error))block {
    NSString *path = [NSString stringWithFormat:@"api/project/%@/member/%@/%@", curPro.id, curMember.user.global_key, curMember.editType];
    [NSObject showStatusBarQueryStr:@"正在设置成员类型"];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showStatusBarSuccessStr:@"成员类型设置成功"];
        } else {
            [NSObject showStatusBarError:error];
        }
        block(data, error);
    }];
}

#pragma mark - Code
- (void)request_CodeBranchOrTagWithPath:(NSString *)path withPro:(Project *)project andBlock:(void (^)(id data, NSError *error))block {
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[project toBranchOrTagPath:path] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            id resultData = [data valueForKey:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"CodeBranchOrTag"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark - Other
- (void)request_VerifyTypeWithBlock:(void (^)(VerifyType type, NSError *error))block {
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/2fa/method" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            VerifyType type = VerifyTypeUnKnow;
            NSString *typeStr = [data valueForKey:@"data"];
            if ([typeStr isEqualToString:@"password"]) {
                type = VerifyTypePassword;
            } else if ([typeStr isEqualToString:@"totp"]) {
                type = VerifyTypeTotp;
            }
            block(type, nil);
        } else {
            block(VerifyTypeUnKnow, error);
        }
    }];
}

@end
