//
//  LoginResponseModel.m
//  EJHttpClientDemo
//
//  Created by iOnRoad on 16/6/28.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import "LoginResponseModel.h"
#import "MJExtension.h"

@implementation LoginResponseModel
MJCodingImplementation

- (instancetype)init
{
    self = [super init];
    if (self) {
        [LoginResponseModel mj_referenceReplacedKeyWhenCreatingKeyValues:YES];
    }
    return self;
}


@end
