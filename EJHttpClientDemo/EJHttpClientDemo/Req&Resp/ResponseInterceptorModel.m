//
//  ResponseInterceptor.m
//  EJHttpClientDemo
//
//  Created by iOnRoad on 16/6/28.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import "ResponseInterceptorModel.h"

@implementation ResponseInterceptorModel

- (BOOL)ej_interceptorResponseObjectWithBizObject:(id)bizObject commonObject:(id)cmnObject{
    return NO;
}

- (BOOL)ej_interceptorResponseParam:(NSDictionary *)param{
    return NO;
}

@end
