//
//  EJHttpRequestInterceptor.h
//  EJDemo
//
//  Created by iOnRoad on 16/4/26.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//
#import <Foundation/Foundation.h>

//需要拦截数据响应时实现
//用于响应数据的拦截，用以处理公共事件，并且拦截后，不再继续下发数据处理业务。
@protocol EJHttpResponseInterceptor <NSObject>

@required
//如果需要拦截，则返回YES，默认需要返回NO，不拦截
- (BOOL)ej_interceptorResponseObjectWithBizObject:(id)bizObject commonObject:(id)cmnObject;
- (BOOL)ej_interceptorResponseParam:(NSDictionary *)param;

@end
