//
//  SettingTextCell.h
//  Coding
//
//  Created by apple on 2018/8/25.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier_SettingText @"SettingTextCell"

@interface SettingTextCell : UITableViewCell

@property(nonatomic,strong)UITextField *textField;

@property(nonatomic,copy)NSString *textValue;
@property(nonatomic,copy)void(^textChangedBlock)(NSString *textValue);

- (void)setTextValue:(NSString *)textValue andTextChangBlock:(void(^)(NSString *textValue))block;

@end
