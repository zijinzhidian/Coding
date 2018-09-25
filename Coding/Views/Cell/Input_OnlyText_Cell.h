//
//  Input_OnlyText_Cell.h
//  Coding
//
//  Created by apple on 2018/4/17.
//  Copyright © 2018年 zjbojin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PhoneCodeButton.h"

#define kCellIdentifier_Input_OnlyText_Cell_Text @"Input_OnlyText_Cell_Text"
#define kCellIdentifier_Input_OnlyText_Cell_Captcha @"Input_OnlyText_Cell_Captcha"
#define kCellIdentifier_Input_OnlyText_Cell_Password @"Input_OnlyText_Cell_Password"
#define kCellIdentifier_Input_OnlyText_Cell_Phone @"Input_OnlyText_Cell_Phone"

@interface Input_OnlyText_Cell : UITableViewCell

@property(nonatomic,strong)UITextField *textField;
@property(nonatomic,assign)BOOL isBottomLineShow;
@property(nonatomic,strong)UILabel *countryCodeL;                   //国家代码文本
@property(nonatomic,strong)PhoneCodeButton *verify_codeBtn;         //发送验证码按钮

@property(nonatomic,copy)void(^textValueChangedBlock)(NSString *text);
@property(nonatomic,copy)void(^editDidBeginBlock)(NSString *text);
@property(nonatomic,copy)void(^editDidEndBlock)(NSString *text);

@property(nonatomic,copy)void(^phoneCodeBtnClickedBlock)(PhoneCodeButton *button);
@property(nonatomic,copy)void(^countryCodeBtnClickedBlock)(void);

- (void)setPlaceholder:(NSString *)phStr value:(NSString *)valueStr;
+ (NSString *)randomCellIdentifierOfPhoneCodeType;

@end
