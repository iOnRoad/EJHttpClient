//
//  EJErrorView.m
//  EJDemo
//
//  Created by iOnRoad on 16/4/29.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import "EJErrorView.h"

@interface EJErrorView ()

@property(copy,nonatomic) EJErrorCancelBlock ej_cancelBlock;
@property(copy,nonatomic) EJErrorConfirmBlock ej_confirmBlock;

@end

@implementation EJErrorView

+ (EJErrorView *)ej_errorViewInContainerView:(UIView *)containerView{
    return [EJErrorView existInView:containerView];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ej_errorTitle = @"";
        self.ej_errorMsg = @"";
    }
    return self;
}

-(void)ej_dismissWithCancel:(EJErrorCancelBlock)cancelBlock confirm:(EJErrorConfirmBlock)confirmBlock{
    self.ej_cancelBlock = [cancelBlock copy];
    self.ej_confirmBlock = [confirmBlock copy];
    [self ej_dismiss];
}

- (void)ej_cancelAction{
    if(self.ej_cancelBlock){
        self.ej_cancelBlock();
    }
}

- (void)ej_confirmAction{
    if(self.ej_confirmBlock){
        self.ej_confirmBlock();
    }
}

- (void)ej_show{}

- (void)ej_dismiss{}


#pragma mark - private methods
+ (EJErrorView *)existInView:(UIView *)mView {
    EJErrorView *errorView = nil;
    for (UIView *subview in mView.subviews) {
        if ([subview isKindOfClass:[self class]]) {
            errorView = (EJErrorView *)subview;
        }
    }
    return errorView;
}

@end
