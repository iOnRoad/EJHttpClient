//
//  EJErrorTip.m
//  EJDemo
//
//  Created by iOnRoad on 15/9/29.
//  Copyright © 2015年 iOnRoad. All rights reserved.
//

#import "EJDefaultErrorView.h"

@implementation EJDefaultErrorView

- (void)ej_show{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.ej_errorTitle message:self.ej_errorMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
