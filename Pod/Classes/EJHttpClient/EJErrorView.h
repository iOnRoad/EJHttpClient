//
//  EJErrorView.h
//  EJDemo
//
//  Created by iOnRoad on 16/4/29.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EJErrorCancelBlock)();
typedef void (^EJErrorConfirmBlock)();

@interface EJErrorView : UIView

+ (EJErrorView *)ej_errorViewInContainerView:(UIView *)containerView;

@property(copy,nonatomic) NSString *ej_errorTitle;
@property(copy,nonatomic) NSString *ej_errorMsg;

- (void)ej_dismissWithCancel:(EJErrorCancelBlock)cancelBlock confirm:(EJErrorConfirmBlock)confirmBlock;

//通用方法,用于显示和隐藏，需要子类重写
- (void)ej_show;
- (void)ej_dismiss;
//取消，或者确认错误，需要子类重写,需要super调用
- (void)ej_cancelAction;
- (void)ej_confirmAction;

@end
