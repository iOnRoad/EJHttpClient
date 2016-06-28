# EJHttpClient
这是一个网络封装框架，将网络请求、加载符、错误提示等封装在一起，通过一句话调用方法进行网络请求。该框架继承AFNetworking和MJExtension，利用对象化概念，将请求参数封装成Model作为请求参数，通过请求回调，将响应参数封装成Model并自动赋值，极大的方便了中间解析的过程，更加专注于业务实现。

##如何安装

利用Cocoapods安装，版本支持7.0以上

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'
inhibit_all_warnings!

target 'EJHttpClientDemo' do

pod 'EJHttpClient', '~> 1.0.0'

end
```

##如何使用它
该框架在初始接入项目时，需要做一些花点时间来进行配置工作，本文讲解很细，请耐心看完，因为一旦接入完毕，将极大的简化开发工作和做相关接口测试工作。  
 通过此框架，基本无需采用MVVM的方式去实现请求代码。


#####开始配置：第一步，注册基本网络请求相关设置

> 介绍：总体需要5个配置，之后将围绕该5个配置进行接入。  
> 1.一般应用都有固定的请求域名，配置应用基本域名URL。  
> 2.一般应用都有通用请求参数，配置指定通用请求参数Model类名，并且针对不同数据的业务参数指定具体的Key。  
> 3.一般应用都有通用响应参数，配置指定通用响应参数Model类名，并且针对不同数据的业务参数指定具体的Key。  
> 4.针对响应请求，配置公共拦截器Model，以拦截处理指定信息的业务逻辑。  
> 5.配置通用加载符类名和通用错误提示符类名。  

基本代码如下：

```objc
- (void)registerAppSetting{
    [[EJHttpClient shared] ej_registerBaseURL:@"https://raw.githubusercontent.com"];
    [[EJHttpClient shared] ej_registerCommonRequestClassName:@"CommonRequestModel"  bizRequestKey:@"data"];
    [[EJHttpClient shared] ej_registerCommonResponseClassName:@"CommonResponseModel" bizResponseKey:@"data"];
    [[EJHttpClient shared] ej_registerInterceptorClassName:@"ResponseInterceptorModel"];
    [[EJHttpClient shared] ej_registerLoadingViewClassName:@"EJDefaultLoadingView" errorViewClassName:@"EJDefaultErrorView"];
	//如果有需要GZIP压缩请求的，还可以启用GZIP
    //[[EJHttpClient shared] ej_enableGzipRequestSerializer];
}
```

#####第二步，配置通用请求对象类和业务请求对象类

请求参数JSON例子如下：

```json
{
	"device_id": "xxxx",
	"version" : "1.0.0",
	"channel": "iOS",
	"data": {
		"username" : "admin",
		"password" : "123456"
	}
}
```

分析：通过以上例子，我们认为，通用请求Model中，方法有3个，分别是`device_id，version,channel` , 而业务请求参数对应的Key则是`data`。 业务请求Model中，方法有2个，分别是`username，password`。因此，我们分别创建通用请求类CommonRequestModel和业务类LoginRequestModel如下：

CommonRequestModel如下：

```objc
#import <Foundation/Foundation.h>

@interface CommonRequestModel : NSObject

@property(copy,nonatomic,readonly) NSString *device_id;
@property(copy,nonatomic,readonly) NSString *version;
@property(copy,nonatomic,readonly) NSString *channel;

@end


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
```

LoginRequestModel如下：

```objc
#import <Foundation/Foundation.h>
#import "EJHttpRequestDelegate.h"

@interface LoginRequestModel : NSObject <EJHttpRequestDelegate>

@property(copy,nonatomic) NSString *username;
@property(copy,nonatomic) NSString *password;

@end

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
```
分析：LoginRequestModel需要实现EJHttpRequestDelegate协议，该协议中定义了 每个请求所需要的基本信息配置。

如`ej_requestURLString`指定该请求的URL。  
如`ej_responseClassName` 指定该请求对应的响应参数Model的类名。它将会自动将请求参数转化为该类的对象并给其属性赋值。  
如`ej_showLoading`,`ej_loadingMessage`,`ej_loadingContainerView`和`ej_endLoadingWhenFinished`是针对加载符的配置，分别标识是否显示加载符，加载符的文案是什么，显示在哪个View上，当请求结束时，是否结束加载符的显示。  
如`ej_showErrorMessage`标识是否显示错误提示。  
如`ej_ignoreDuplicateRequest`标识有多次请求的情况下，是否忽略重复多余的请求。

> 建议：最好建个请求Model基类，将这些协议按默认方案实现完毕，然后在某个具体的业务类中继承基类，并适当的修改某些方法的返回值来达到指定的目的，就不用每个类中这么复杂的实现了。

如LoginSubRequestModel类继承LoginRequestModel，仅仅实现2个就好，分别指定请求URL和响应对象类名,其他设置按基类默认设置,则实现如下：

```objc
@interface LoginSubRequestModel : LoginRequestModel

@end

@implementation LoginSubRequestModel

- (NSString *)ej_requestURLString{
    return @"/user/login.json";
}

- (NSString *)ej_responseClassName{
    return @"loginSubResponseModel";
}

@end
```
#####第三步，配置通用响应对象类和业务响应对象类

响应参数JSON例子如下：

```json
{
    "flag": true,
    "errorCode": 16,
    "errorMsg": "error info",
    "data": {
        "username": "admin",
        "userToken": "123456"
    }
}
```

分析：通过以上例子，我们认为，通用响应Model中，方法有3个，分别是`flag，errorCode,errorMsg` , 而业务响应参数对应的Key则是`data`。 业务响应Model中，方法有2个，分别是`username，userToken`。因此，我们分别创建通用响应类CommonResponseModel和业务类LoginResponseModel如下：

CommonResponseModel如下：

```objc
#import <Foundation/Foundation.h>
#import "EJHttpResponseDelegate.h"

@interface CommonResponseModel : NSObject <EJHttpResponseDelegate>

@property(assign,nonatomic) BOOL flag;
@property(assign,nonatomic) NSInteger errorCode;
@property(copy,nonatomic) NSString *errorMsg;

@end

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
```

LoginResponseModel如下：

```objc
@interface LoginResponseModel : NSObject

@property(copy,nonatomic) NSString *username;
@property(copy,nonatomic) NSString *userToken;

@end

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
```

分析：CommonResponseModel类需要实现EJHttpResponseDelegate协议，来标识通用请求正确性的判断，错误标题以及错误内容。一般用于通用响应标识即可。如果具体某个请求响应标识的错误信息提示比较特别，则也可以在具体响应类上实现协议并指定。


#####第四步：配置拦截器

```objc
#import <Foundation/Foundation.h>
#import "EJHttpResponseInterceptor.h"

@interface ResponseInterceptorModel : NSObject <EJHttpResponseInterceptor>

@end

@implementation ResponseInterceptorModel

- (BOOL)ej_interceptorResponseObjectWithBizObject:(id)bizObject commonObject:(id)cmnObject{
    CommonResponseModel *cmnModel = (CommonResponseModel *)cmnObject;
    NSLog(@"cmnModel errorCode: %ld",cmnModel.errorCode);
    NSLog(@"cmnModel errorMsg: %@",cmnModel.errorMsg);

    if([bizObject isKindOfClass:[LoginResponseModel class]]){
        LoginResponseModel *model = (LoginResponseModel *)bizObject;
        if([@"admin" isEqualToString:model.username]){
            NSLog(@"admin request is intercepted. ");
            return YES;
        }else{
            NSLog(@"this request is not intercepted.");
        }
    }
    return NO;
}

- (BOOL)ej_interceptorResponseParam:(NSDictionary *)param{
    NSInteger errorCode = [param[@"errorCode"] integerValue];
    NSString *errorMsg = param[@"errorMsg"];
    NSLog(@"errorCode: %ld",errorCode);
    NSLog(@"errorMsg: %@",errorMsg);
    
    NSDictionary *data = param[@"data"];
    if(data){
        NSString *username = data[@"username"];
        if([@"admin" isEqualToString:username]){
            NSLog(@"admin request is intercepted. ");
            return YES;
        }else{
            NSLog(@"this request is not intercepted.");
        }
    }
    
    return NO;
}

@end
```

分析:需要实现EJHttpResponseInterceptor协议  
`ej_interceptorResponseObjectWithBizObject`是针对对象入参出参的请求方式进行拦截。  
`ej_interceptorResponseParam`是针对字典方式入参出参进行的拦截.

#####最后一步：配置加载符和错误提示

**错误提示：**  
需要根据自己的项目，实现对应的错误提示界面，但需要继承EJErrorView，并实现- (void)ej_show;在该方法实现展示方式，具体参考Demo。

**加载符：**  
需要根据自己的项目，实现对应的加载提示界面，但需要继承EJLoadingVIew，并实现`- (void)ej_showInView:(UIView *)mView;`和
`- (void)ej_dismiss;`，在该方法中实现展示和隐藏方式，具体参考Demo。


##如何调用它

经过以上配置后，就可以进行调用了，调用方式如下：

```objc
  LoginRequestModel *model = [LoginRequestModel new];
//    model.username = @"admin";
//    model.password = @"123456";
    
    [[EJHttpClient shared] ej_requestParamObject:model method:GET responseHandler:^(id respObject, BOOL success) {
        if(success){
            LoginResponseModel *respModel = (LoginResponseModel *)respObject;
            NSLog(@"username:%@",respModel.username);
            NSLog(@"userToken:%@",respModel.userToken);
        }else{
            NSLog(@"error!");
        }
    }];
```

看到最后一步，是不是很简便的在程序中调用网络请求了。虽然配置上看起来繁琐了一些，但是实际操作并不繁琐，仅仅是在开始繁琐了一些，以后则极大的提高了开发效率。


##更多用法
请下载demo查阅。我相信该框架对于您在项目中的开发会有很大效率的提高。  












