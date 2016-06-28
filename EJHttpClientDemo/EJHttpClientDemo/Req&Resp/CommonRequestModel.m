//
//  CommonRequestModel.m
//  EJHttpClientDemo
//
//  Created by iOnRoad on 16/6/28.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import "CommonRequestModel.h"
#import "MJExtension.h"

@implementation CommonRequestModel
MJCodingImplementation

- (instancetype)init
{
    self = [super init];
    if (self) {
        [CommonRequestModel mj_referenceReplacedKeyWhenCreatingKeyValues:YES];

        _channel = @"iOS";
        _version = @"1.0.0";
        _device_id =  @"xxxx";
    }
    return self;
}

@end
