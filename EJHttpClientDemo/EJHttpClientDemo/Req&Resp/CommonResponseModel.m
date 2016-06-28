//
//  CommonResponseModel.m
//  EJHttpClientDemo
//
//  Created by iOnRoad on 16/6/28.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import "CommonResponseModel.h"
#import "MJExtension.h"

@implementation CommonResponseModel
MJCodingImplementation

- (instancetype)init
{
    self = [super init];
    if (self) {
        [CommonResponseModel mj_referenceReplacedKeyWhenCreatingKeyValues:YES];
    }
    return self;
}

-(BOOL)ej_resultFlag{
    return self.flag;
}

- (NSString *)ej_errorTitle{
    return @"";
}

- (NSString *)ej_errorMessage{
    return self.errorMsg;
}

@end
