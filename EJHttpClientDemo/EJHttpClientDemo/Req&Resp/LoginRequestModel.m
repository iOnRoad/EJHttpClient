//
//  LoginRequestModel.m
//  EJHttpClientDemo
//
//  Created by iOnRoad on 16/6/28.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import "LoginRequestModel.h"
#import "MJExtension.h"
#import "ViewController.h"

@implementation LoginRequestModel
MJCodingImplementation

- (instancetype)init
{
    self = [super init];
    if (self) {
        [LoginRequestModel mj_referenceReplacedKeyWhenCreatingKeyValues:YES];
    }
    return self;
}

- (NSString *)ej_requestURLString{
    return @"iOnRoad/EJHttpClient/master/response.json";
}

- (NSString *)ej_responseClassName{
    return @"LoginResponseModel";
}

- (BOOL)ej_showLoading{
    return YES;
}

- (NSString *)ej_loadingMessage{
    return @"加载中";
}

- (UIView *)ej_loadingContainerView{
    return [ViewController currentController].view;
}

- (BOOL)ej_endLoadingWhenFinished{
    return YES;
}

- (BOOL)ej_showErrorMessage{
    return NO;
}

- (BOOL)ej_ignoreDuplicateRequest{
    return YES;
}

@end
