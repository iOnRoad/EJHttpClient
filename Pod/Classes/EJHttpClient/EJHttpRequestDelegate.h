//
//  EJHttpRequestDelegate.h
//  EJDemo
//
//  Created by iOnRoad on 16/4/26.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//必须需要类实现
//请求信息
@protocol EJHttpRequestDelegate <NSObject>

@required
- (NSString *)ej_requestURLString;      //请求地址
- (NSString *)ej_responseClassName;     //请求对应的响应类名

- (BOOL)ej_showLoading;        //是否显示Loading
- (NSString *)ej_loadingMessage;       //loading显示文本设置
- (UIView *)ej_loadingContainerView;       //loading显示容器
- (BOOL)ej_endLoadingWhenFinished;     //请求结束后是否需要隐藏loading
- (BOOL)ej_showErrorMessage;   //是否显示错误信息
- (BOOL)ej_ignoreDuplicateRequest;     //是否忽略重复请求

@end