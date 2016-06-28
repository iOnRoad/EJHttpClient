//
//  ResponseInterceptor.m
//  EJHttpClientDemo
//
//  Created by iOnRoad on 16/6/28.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import "ResponseInterceptorModel.h"
#import "CommonResponseModel.h"
#import "LoginResponseModel.h"

@implementation ResponseInterceptorModel

- (BOOL)ej_interceptorResponseObjectWithBizObject:(id)bizObject commonObject:(id)cmnObject{
    CommonResponseModel *cmnModel = (CommonResponseModel *)cmnObject;
    NSLog(@"cmnModel errorCode: %ld",cmnModel.errorCode);
    NSLog(@"cmnModel errorMsg: %@",cmnModel.errorMsg);

    if([bizObject isKindOfClass:[LoginResponseModel class]]){
        LoginResponseModel *model = (LoginResponseModel *)bizObject;
        if([@"admin" isEqualToString:model.username]){
            NSLog(@"admin request is intercepted. ");
            return YES;
        }else{
            NSLog(@"this request is not intercepted.");
        }
    }
    return NO;
}

- (BOOL)ej_interceptorResponseParam:(NSDictionary *)param{
    return NO;
}

@end
