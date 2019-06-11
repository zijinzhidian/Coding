//
//  UILongPressMenuImageView.m
//  Coding
//
//  Created by apple on 2019/5/22.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "UILongPressMenuImageView.h"
#import <objc/runtime.h>

@implementation UILongPressMenuImageView

//必须要有第一响应者,实现该方法
- (BOOL)canBecomeFirstResponder{
    if (self.longPressMenuBlock) {
        return YES;
    }else{
        return [super canBecomeFirstResponder];
    }
}

//必须要得通过第一响应者，来告诉MenuController它内部应该显示什么内容，监听哪些操作action
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (self.longPressMenuBlock) {
        for (int i=0; i<self.longPressTitles.count; i++) {
            if (action == NSSelectorFromString([NSString stringWithFormat:@"easeLongPressMenuClicked_%d:", i])) {
                return YES;
            }
        }
        return NO;
    }else{
        return [super canPerformAction:action withSender:sender];
    }
}

- (void)addLongPressMenu:(NSArray *)titles clickBlock:(void(^)(NSInteger index, NSString *title))block {
    self.longPressMenuBlock = block;
    self.longPressTitles = titles;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPress];
}


- (void)handleLongPress:(UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:self.longPressTitles.count];
        Class cls = [self class];
        SEL imp = @selector(longPressMenuClicked:);
        for (int i=0; i<self.longPressTitles.count; i++) {
            NSString *title = [self.longPressTitles objectAtIndex:i];
            //注册名添加方法sel，sel的具体实现在imp(longPressMenuClicked:)
            SEL sel = sel_registerName([[NSString stringWithFormat:@"easeLongPressMenuClicked_%d:", i] UTF8String]);
            class_addMethod(cls, sel, [cls instanceMethodForSelector:imp], "v@");
            UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:title action:sel];
            [menuItems addObject:menuItem];
        }
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:menuItems];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)longPressMenuClicked:(id)sender {
    NSString *selStr = NSStringFromSelector(_cmd);
    NSString *preFix = @"easeLongPressMenuClicked_";
    NSString *indexStr = [selStr substringFromIndex:preFix.length];
    NSInteger index = indexStr.integerValue;
    if (index >=0 && index<self.longPressTitles.count) {
        NSString *title = [self.longPressTitles objectAtIndex:index];
        if (self.longPressMenuBlock) {
            self.longPressMenuBlock(index, title);
        }
    }
}

@end
