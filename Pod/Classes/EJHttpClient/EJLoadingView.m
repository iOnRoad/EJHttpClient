//
//  EJLoadingView.m
//  EJDemo
//
//  Created by iOnRoad on 16/4/29.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import "EJLoadingView.h"

@implementation EJLoadingView

#pragma mark - init
+ (EJLoadingView *)ej_loadingInContainerView:(UIView *)containerView{
    return [self ej_existInView:containerView];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ej_loadingMsg = @"加载中";
    }
    return self;
}

#pragma mark - public methods
- (void)ej_showInWindow{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [self ej_showInView:window];
}

- (void)ej_showInView:(UIView *)mView{
    if(mView){
        if([EJLoadingView ej_existInView:mView]){
            return;
        }
        self.frame = mView.bounds;
        [mView addSubview:self];
        [self ej_startAnimation];
    }
}

- (void)ej_dismiss{
    [self ej_stopAnimation];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if(finished){
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - subclass can override

- (void)ej_startAnimation{}

- (void)ej_stopAnimation{}


#pragma mark - private methods
+ (EJLoadingView *)ej_existInView:(UIView *)mView {
    EJLoadingView *loading = nil;
    for (UIView *subview in mView.subviews) {
        if ([subview isKindOfClass:[self class]]) {
            loading = (EJLoadingView *)subview;
        }
    }
    return loading;
}

@end
