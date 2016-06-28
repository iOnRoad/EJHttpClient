//
//  EJLoadingView.h
//  EJDemo
//
//  Created by iOnRoad on 16/4/29.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EJLoadingView : UIView

+ (EJLoadingView *)ej_loadingInContainerView:(UIView *)containerView;

@property(copy,nonatomic) NSString *ej_loadingMsg;     //加载提示文案

//通用方法，子类可直接调用,用于显示和隐藏
- (void)ej_showInWindow;
- (void)ej_showInView:(UIView *)mView;
- (void)ej_dismiss;

//展示动画空方法，如子类需要，可重写实现
- (void)ej_startAnimation;
- (void)ej_stopAnimation;

@end
