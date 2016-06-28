//
//  ViewController.m
//  EJHttpClientDemo
//
//  Created by iOnRoad on 16/6/28.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import "ViewController.h"
#import "EJHttpClient.h"
#import "LoginRequestModel.h"
#import "LoginResponseModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    LoginRequestModel *model = [LoginRequestModel new];
    model.username = @"admin";
    model.password = @"123456";
    
    [[EJHttpClient shared] ej_requestPostParamObject:model responseHandler:^(id respObject, BOOL success) {
        if(success){
            LoginResponseModel *respModel = (LoginResponseModel *)respObject;
            NSLog(@"username:%@",respModel.username);
            NSLog(@"userToken:%@",respModel.userToken);
        }
    }];
    
    //第二种方式
    [[EJHttpClient shared] ej_requestWithURLString:@"http://www.test.com/user/register.json" method:POST param:@{@"username":@"admin",@"password":@"123456"} responseHandler:^(NSDictionary *param, NSError *error, BOOL isInterceptor) {
        if(isInterceptor){
            //处理拦截事件
        }
        if(!error){
            NSLog(@"param:%@",param);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
