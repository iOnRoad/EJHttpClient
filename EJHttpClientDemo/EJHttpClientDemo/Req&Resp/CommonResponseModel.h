//
//  CommonResponseModel.h
//  EJHttpClientDemo
//
//  Created by iOnRoad on 16/6/28.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EJHttpResponseDelegate.h"

@interface CommonResponseModel : NSObject <EJHttpResponseDelegate>

@property(assign,nonatomic) BOOL flag;
@property(assign,nonatomic) NSInteger errorCode;
@property(copy,nonatomic) NSString *errorMsg;

@end
