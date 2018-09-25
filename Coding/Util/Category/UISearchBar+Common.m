//
//  UISearchBar+Common.m
//  Coding
//
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "UISearchBar+Common.h"

@implementation UISearchBar (Common)

- (UITextField *)eaTextField {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UIView *candidateView, NSDictionary *bindings) {
        return [candidateView isMemberOfClass:NSClassFromString(@"UISearchBarTextField")];
    }];
    return [self.subviews.firstObject.subviews filteredArrayUsingPredicate:predicate].lastObject;
//    return [self valueForKey:@"_searchField"];
}

- (void)setPlaceholderColor:(UIColor *)color {
    [[self valueForKey:@"_searchField"] setValue:color forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)setSearchIcon:(UIImage *)image {
    [self setImage:image forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
}

@end
