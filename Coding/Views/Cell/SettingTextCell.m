//
//  SettingTextCell.m
//  Coding
//
//  Created by apple on 2018/8/25.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "SettingTextCell.h"

@implementation SettingTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textField.text = self.textValue;
}

- (void)setTextValue:(NSString *)textValue andTextChangBlock:(void(^)(NSString *textValue))block {
    [self.textField becomeFirstResponder];
    if ([textValue isEqualToString:@"未填写"]) {
        _textValue = nil;
    } else {
        _textValue = textValue;
    }
    _textChangedBlock = block;
}

- (void)textValueChanged:(UITextField *)textField {
    _textValue = textField.text;
    if (_textChangedBlock) {
        _textChangedBlock(_textValue);
    }
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7, kScreen_Width - kPaddingLeftWidth * 2, 30)];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.font = [UIFont systemFontOfSize:16];
        _textField.textColor = [UIColor blackColor];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.placeholder = @"未填写";
        [_textField addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

@end
