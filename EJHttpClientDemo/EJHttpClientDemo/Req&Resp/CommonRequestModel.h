//
//  CommonRequestModel.h
//  EJHttpClientDemo
//
//  Created by iOnRoad on 16/6/28.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonRequestModel : NSObject

@property(copy,nonatomic,readonly) NSString *device_id;
@property(copy,nonatomic,readonly) NSString *version;
@property(copy,nonatomic,readonly) NSString *channel;

@end
