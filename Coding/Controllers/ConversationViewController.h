//
//  ConversationViewController.h
//  Coding
//
//  Created by apple on 2019/5/21.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "BaseViewController.h"
#import "PrivateMessages.h"
#import "QBImagePickerController.h"
#import "UIMessageInputView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConversationViewController : BaseViewController

@property(nonatomic, strong)PrivateMessages *myPriMsgs;

- (void)doPoll;

@end

NS_ASSUME_NONNULL_END
