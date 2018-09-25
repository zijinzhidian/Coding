//
//  CountryCodeListViewController.h
//  Coding
//
//  Created by apple on 2018/5/3.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "BaseViewController.h"

@interface CountryCodeListViewController : BaseViewController
@property(nonatomic,copy)void(^selectedBlock)(NSDictionary *countryCodeDict);      
@end
