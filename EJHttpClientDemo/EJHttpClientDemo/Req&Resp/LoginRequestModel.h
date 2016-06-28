//
//  LoginRequestModel.h
//  EJHttpClientDemo
//
//  Created by iOnRoad on 16/6/28.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EJHttpRequestDelegate.h"

@interface LoginRequestModel : NSObject <EJHttpRequestDelegate>

@property(copy,nonatomic) NSString *username;
@property(copy,nonatomic) NSString *password;

@end
