
//
//  LoginSubRequestModel.m
//  EJHttpClientDemo
//
//  Created by iOnRoad on 16/6/28.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import "LoginSubRequestModel.h"

@implementation LoginSubRequestModel

- (NSString *)ej_requestURLString{
    return @"/user/login.json";
}

- (NSString *)ej_responseClassName{
    return @"loginSubResponseModel";
}

- (BOOL)ej_showLoading{
    return NO;
}

@end
