//
//  OTPTableViewCell.h
//  Coding
//
//  Created by apple on 2018/4/27.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTPAuthURL.h"

@interface OTPTableViewCell : UITableViewCell
@property(strong,nonatomic)OTPAuthURL *authURL;
+ (CGFloat)cellHeight;
@end


@interface TOTPTableViewCell : OTPTableViewCell
@end

@interface HOTPTableViewCell : OTPTableViewCell
@end
