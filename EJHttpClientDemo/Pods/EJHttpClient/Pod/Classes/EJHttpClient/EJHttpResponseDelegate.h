//
//  EJHttpResponseDelegate.h
//  EJDemo
//
//  Created by iOnRoad on 16/4/26.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//
#import <Foundation/Foundation.h>

//必须需要类实现
//一般用在业务基类或公共响应类来返回错误结果以及错误信息，用以公共提示业务错误信息
@protocol EJHttpResponseDelegate <NSObject>

@required
- (BOOL)ej_resultFlag;      //请求结果标识，用于弹出错误提示判断
- (NSString *)ej_errorTitle;        //要弹的错误标题
- (NSString *)ej_errorMessage;      //要弹的错误信息

@end
