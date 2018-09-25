//
//  ProjectSettingViewController.m
//  Coding
//
//  Created by apple on 2018/8/18.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ProjectSettingViewController.h"
#import "Login.h"

@interface ProjectSettingViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property(nonatomic,strong)UIBarButtonItem *submitButtonItem;
@property(nonatomic,strong)UIImageView *projectIconImage;
@property(nonatomic,strong)MBProgressHUD *uploadHUD;
@end

@implementation ProjectSettingViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"项目设置";
   
    //项目图片
    [self.projectImageView sd_setImageWithURL:[self.project.icon urlImageWithCodePathResizeToView:self.projectImageView] placeholderImage:kPlaceholderCodingSquareWidth(55.0)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectProjectImage)];
    [self.projectImageView addGestureRecognizer:tap];
    
    //项目私有图标
    if ([self.project.is_public isEqual:@YES]) {
        self.privateImageView.hidden = YES;
    }
    
    //项目名称
    self.projectNameF.text = self.project.name;
    
    //项目描述
    self.descTextView.placeholder = @"填写项目描述...";
    self.descTextView.text = self.project.description_mine;
    
    //添加完成按钮
    if ([self p_canEditPro]) {
        self.submitButtonItem = [UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(submit)];
        self.submitButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem = self.submitButtonItem;
        RAC(self, submitButtonItem.enabled) = [RACSignal combineLatest:@[self.projectNameF.rac_textSignal, self.descTextView.rac_textSignal] reduce:^id (NSString *name, NSString *desc){
            BOOL hasChange = ![name isEqualToString:self.project.name] || ![desc isEqualToString:self.project.description_mine];
            return @(hasChange);
        }];
    }
    
    //进度条
    self.uploadHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.uploadHUD.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:self.uploadHUD];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = [segue destinationViewController];
    [vc setValue:self.project forKey:@"project"];
}

#pragma mark - Private Methods
//是否为项目拥有者
- (BOOL)p_isOwner {
    return [self.project.owner_id isEqual:[Login curLoginUser].id];
}

//是否能编辑项目
- (BOOL)p_canEditPro{
    return _project.current_user_role_id.integerValue >= 90;
}

//选择项目图像
- (void)selectProjectImage {
    [UIAlertController showSheetViewWithTitle:@"选择照片" buttonTitles:@[@"拍照", @"从相册选择"] didDismissBlock:^(NSInteger index) {
        if (index < 0) return;
        
        UIImagePickerController *avatarPicker = [[UIImagePickerController alloc] init];
        avatarPicker.delegate = self;
        avatarPicker.allowsEditing = YES;
        if (index == 0) {
            avatarPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if (index == 1) {
            avatarPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:avatarPicker animated:YES completion:nil];
    }];
}

- (void)submit {
    self.project.name = [self.projectNameF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.project.description_mine = [self.descTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    self.submitButtonItem.enabled = NO;
    
    //更新项目
    [[Coding_NetAPIManager sharedManager] request_UpdateProject_WithObj:self.project andBlock:^(Project *data, NSError *error) {
        if (!error) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        self.submitButtonItem.enabled = NO;
    }];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [self p_canEditPro] ? 2: 0;
    }else if (section == 1){
        return [self p_isOwner]? 3: 0;
    }else{
        return [self p_isOwner]? 0: 1;
    }
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [self p_isOwner]? 15: 0;
    }else if (section == 1){
        return [self p_isOwner]? 15: 0;
    }else{
        return [self p_isOwner]? 0: 15;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:13];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self.view endEditing:YES];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image) {
        self.uploadHUD.progress = 0;
        [self.uploadHUD showAnimated:YES];
        [[Coding_NetAPIManager sharedManager] request_UpdateProject_WithObj:self.project icon:image andBlock:^(id data, NSError *error) {
            if (data) {
                self.privateImageView.image = image;
            }
            [self.uploadHUD hideAnimated:YES];
        } progressBlock:^(CGFloat progressValue) {
            dispatch_async(dispatch_get_main_queue(), ^{
              self.uploadHUD.progress = progressValue;
            });
        }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [JDStatusBarNotification showWithStatus:@"正在上传项目图标" styleName:JDStatusBarStyleSuccess];
        [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleWhite];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
