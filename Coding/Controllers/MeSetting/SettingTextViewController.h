//
//  SettingTextViewController.h
//  Coding
//
//  Created by apple on 2018/8/25.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, SettingType) {
    SettingTypeOnlyText = 0,
    SettingTypeFolderName,
    SettingTypeNewFolderName,
    SettingTypeFileVersionRemark,
    SettingTypeFileName
};

@interface SettingTextViewController : BaseViewController

@property(nonatomic,copy)NSString *textValue, *placeholderStr;
@property(nonatomic,copy)void(^doneBlock)(NSString *textValue);
@property(nonatomic,assign)SettingType settingType;

+ (instancetype)settingTextVCWithTitle:(NSString *)title textValue:(NSString *)textValue doneBlock:(void(^)(NSString *textValue))block;

@end
