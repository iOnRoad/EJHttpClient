//
//  EJHttpClient.m
//  EJDemo
//
//  Created by iOnRoad on 16/4/26.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import "EJHttpClient.h"
#import "AFNetworking.h"
#import "AFgzipRequestSerializer.h"
#import "Reachability.h"
#import "MJExtension.h"

@interface EJHttpClient ()

@property(copy,nonatomic) NSString *ej_baseURL;
@property(copy,nonatomic) NSString *ej_interceptorClassName;
@property(copy,nonatomic) NSString *ej_commonRequestClassName;
@property(copy,nonatomic) NSString *ej_commonResponseClassName;
@property(copy,nonatomic) NSString *ej_requestKey;
@property(copy,nonatomic) NSString *ej_responseKey;
@property(copy,nonatomic) NSString *ej_loadingViewClassName;
@property(copy,nonatomic) NSString *ej_errorViewClassName;
@property(assign,nonatomic) BOOL ej_isEnableGzip;

@property(strong,nonatomic) NSMutableDictionary *ej_loadingDict;
@property(strong,nonatomic) NSMutableDictionary *ej_requestOperationDict;
@property(strong,nonatomic) AFHTTPRequestOperationManager *ej_httpManager;
@property(strong,nonatomic) AFHTTPRequestOperationManager *ej_opManager;

//handle object request
- (void)ej_handleSuccessResultWithRequest:(id<EJHttpRequestDelegate>)request responseObject:(id)responseObject  responseHandler:(EJHttpHandler)handler commonResponseHandler:(EJHttpCommonHandler)cmnHandler;
- (void)ej_handleFailedResultWithRequest:(id<EJHttpRequestDelegate>)request error:(NSError *)error  responseHandler:(EJHttpHandler)handler commonResponseHandler:(EJHttpCommonHandler)cmnHandler;
- (void)ej_handlerResponseParam:(NSDictionary *)param withError:(NSError *)error responseHandler:(EJHttpParamHandler)handler;

@end

@implementation EJHttpClient

#pragma mark - init methods
static EJHttpClient *ej_sharedHttpClient = nil;
+ (instancetype)shared
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{ ej_sharedHttpClient = [[EJHttpClient alloc] init]; });
    return ej_sharedHttpClient;
}

/**
 *  初始化
 *  @return id
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化请求队列
        self.ej_baseURL = @"";
        self.ej_requestKey = @"";
        self.ej_commonRequestClassName = @"";
        self.ej_responseKey = @"";
        self.ej_commonResponseClassName = @"";
        self.ej_interceptorClassName = @"";
        self.ej_loadingViewClassName = @"";
        self.ej_errorViewClassName = @"";
        self.ej_isEnableGzip = NO;
        
        self.ej_loadingDict = [NSMutableDictionary dictionaryWithCapacity:0];
        self.ej_requestOperationDict = [NSMutableDictionary dictionaryWithCapacity:0];
        
        _ej_httpManager = [AFHTTPRequestOperationManager manager];
        _ej_opManager = nil;
    }
    return self;
}

- (void)ej_registerBaseURL:(NSString *)urlString{
    self.ej_baseURL = urlString;
    _ej_opManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:self.ej_baseURL]];
}


//注册基本信息
- (void)ej_registerInterceptorClassName:(NSString *)interceptorClassName{
    self.ej_interceptorClassName = interceptorClassName;
}

- (void)ej_registerCommonRequestClassName:(NSString *)commonRequestClassName bizRequestKey:(NSString *)requestKey{
    self.ej_commonRequestClassName  = commonRequestClassName;
    self.ej_requestKey = requestKey;
}

- (void)ej_registerCommonResponseClassName:(NSString *)commonResponseClassName bizResponseKey:(NSString *)responseKey{
    self.ej_commonResponseClassName = commonResponseClassName;
    self.ej_responseKey = responseKey;
}

- (void)ej_registerLoadingViewClassName:(NSString *)loadingViewClassName errorViewClassName:(NSString *)errorViewClassName{
    self.ej_loadingViewClassName = loadingViewClassName;
    self.ej_errorViewClassName = errorViewClassName;
}

- (void)ej_enableGzipRequestSerializer{
    self.ej_isEnableGzip = YES;
}

#pragma mark - object request methods
- (void)ej_requestPostParamObject:(id <EJHttpRequestDelegate>)request responseHandler:(EJHttpHandler)handler{
    [self ej_requestParamObject:request method:POST responseHandler:handler];
}

- (void)ej_requestParamObject:(id <EJHttpRequestDelegate>)request method:(EJHttpRequestMethod)method responseHandler:(EJHttpHandler)handler{
    [self ej_requestParamObject:request method:method responseHandler:handler commonHandler:nil];
}

- (void)ej_requestPostParamObject:(id <EJHttpRequestDelegate>)request responseCommonHandler:(EJHttpCommonHandler)commonHandler{
    [self ej_requestParamObject:request method:POST responseCommonHandler:commonHandler];
}

- (void)ej_requestParamObject:(id <EJHttpRequestDelegate>)request method:(EJHttpRequestMethod)method responseCommonHandler:(EJHttpCommonHandler)commonHandler{
    [self ej_requestParamObject:request method:method responseHandler:nil commonHandler:commonHandler];
}

//对象模式最终转化字典模式进行请求
- (void)ej_requestParamObject:(id <EJHttpRequestDelegate>)request method:(EJHttpRequestMethod)method responseHandler:(EJHttpHandler)handler commonHandler:(EJHttpCommonHandler)commonHandler{
    NSString *urlString = [request ej_requestURLString];
    if(urlString.length==0){
        NSLog(@"###WARNING：URL IS NULL !!!");
        return;
    }
    //收集请求参数
    NSDictionary *bodyParam = [self ej_bodyParamWithRequest:request];
    NSLog(@"###Start Request URL:%@",  [[NSURL URLWithString:urlString relativeToURL:[NSURL URLWithString:self.ej_baseURL]] absoluteString]);
    NSLog(@"###Start Request Param:%@",bodyParam.description);
    
    //发起请求,先判断请求是否存在队列中,如果在，在取消已有请求
    AFHTTPRequestOperationManager *manager = [self ej_requestManagerWithURLString:urlString];
    if([request ej_ignoreDuplicateRequest]){
        for(AFURLConnectionOperation *op in manager.operationQueue.operations){
            if([op.request.URL.absoluteString rangeOfString:urlString].length>0){
                NSURLRequest *urlRequest =  [manager.requestSerializer requestBySerializingRequest:op.request withParameters:bodyParam error:nil];
                //如果URL一直，并且请求体一直，则取消请求
                if([urlRequest.HTTPBody isEqualToData:op.request.HTTPBody]){
                    NSLog(@"Cancel Request URL:%@",op.request.URL.absoluteString);
                    [op cancel];
                }
            }
        }
    }
    
    //开启加载符
    [self ej_showLoadingWithRequest:request];
    //发起请求
    __weak typeof(self) weakSelf = self;
    switch (method) {
        case GET:
        {
            [manager GET:urlString parameters:bodyParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [weakSelf ej_handleSuccessResultWithRequest:request responseObject:responseObject responseHandler:handler commonResponseHandler:commonHandler];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [weakSelf ej_handleFailedResultWithRequest:request error:error responseHandler:handler commonResponseHandler:commonHandler];
            }];
        }
            break;
        case POST:
        {
            [manager POST:urlString parameters:bodyParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [weakSelf ej_handleSuccessResultWithRequest:request responseObject:responseObject responseHandler:handler commonResponseHandler:commonHandler];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [weakSelf ej_handleFailedResultWithRequest:request error:error responseHandler:handler commonResponseHandler:commonHandler];
            }];
        }
    }
}

#pragma mark - param request methods
- (void)ej_requestWithURLString:(NSString *)urlString method:(EJHttpRequestMethod)method param:(NSDictionary *)param responseHandler:(EJHttpParamHandler)handler{
    if(urlString.length==0){
        NSLog(@"###WARNING：URL IS NULL !!!");
        if(handler){
            handler(nil,nil,NO);
        }
        return;
    }
    //开始发起请求
    NSDictionary *bodyParam = [self ej_bodyParamWithRequestParam:param];
    NSLog(@"###Start Request URL:%@",urlString);
    NSLog(@"###Start Request Param:%@",bodyParam.description);
    //发起请求
    __weak typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager *manager = [self ej_requestManagerWithURLString:urlString];
    switch (method) {
        case GET:
        {
            [manager GET:urlString parameters:bodyParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if(handler){
                    [weakSelf ej_handlerResponseParam:responseObject withError:nil responseHandler:handler];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if(handler){
                    [weakSelf ej_handlerResponseParam:nil withError:error responseHandler:handler];
                }
            }];
        }
            break;
        case POST:
        {
            [manager POST:urlString parameters:bodyParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if(handler){
                    [weakSelf ej_handlerResponseParam:responseObject withError:nil responseHandler:handler];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if(handler){
                    [weakSelf ej_handlerResponseParam:nil withError:error responseHandler:handler];
                }
            }];
        }
    }
}

#pragma mark - upload image methods
- (void)ej_requestUploadFileWithURLString:(NSString *)urlString param:(NSDictionary *)param name:(NSString *)name fileData:(NSData *)fileData fileName:(NSString *)fileName mimeType:(NSString *)miniType responseHandler:(EJHttpParamHandler)handler progress:(EJHttpProgressHandler)progressHandler{
    if(urlString.length==0){
        NSLog(@"###WARNING：URL IS NULL !!!");
        if(handler){
            handler(nil,nil,NO);
        }
        return;
    }
    NSDictionary *bodyParam = [self ej_bodyParamWithRequestParam:param];
    NSLog(@"###Start Request URL:%@",urlString);
    NSLog(@"###Start Request Param:%@",bodyParam.description);
    NSLog(@"###Start Request filename:%@",fileName);

    //发起请求
    __weak typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager *manager = [self ej_requestUploadFileManagerWithURLString:urlString];
    AFHTTPRequestOperation *uploadOperation = [manager POST:urlString parameters:bodyParam constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if(fileData){
            [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:miniType];
        }
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if(handler){
            [weakSelf ej_handlerResponseParam:responseObject withError:nil responseHandler:handler];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        if(handler){
            [weakSelf ej_handlerResponseParam:nil withError:error responseHandler:handler];
        }
    }];
    
    [uploadOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        if(progressHandler){
            progressHandler(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
        }
    }];
}

#pragma mark - object response methods
- (void)ej_handleSuccessResultWithRequest:(id<EJHttpRequestDelegate>)request responseObject:(id)responseObject  responseHandler:(EJHttpHandler)handler commonResponseHandler:(EJHttpCommonHandler)cmnHandler{
    NSLog(@"request URL:%@\nResponse :%@",[request ej_requestURLString],responseObject);
    //转换成公共响应数据
    Class cmnObjectClass = NSClassFromString(self.ej_commonResponseClassName);
    NSObject *cmnObj = nil;
    NSObject *bizObj  = nil;
    if(cmnObjectClass){
        //需要判断类是否存在，存在，则需要区分公共响应和业务响应
        cmnObj = [cmnObjectClass mj_objectWithKeyValues:responseObject];
        //转换业务数据
        NSDictionary *bizDic = ((NSDictionary *)responseObject)[self.ej_responseKey];
        NSString *responeClassName = [request ej_responseClassName];
        Class bizObjectClass = NSClassFromString(responeClassName);
        if(!bizObjectClass){
            NSLog(@"%@ Class isn't exist,Please check it.",responeClassName);
            [self ej_dismissLoadingWithRequest:request];
            return;
        }
        bizObj = [bizObjectClass mj_objectWithKeyValues:bizDic];
    }else {
        //直接将返回数据转换成响应对象
        NSString *responeClassName = [request ej_responseClassName];
        Class bizObjectClass = NSClassFromString(responeClassName);
        if(!bizObjectClass){
            NSLog(@"%@ Class isn't exist,Please check it.",responeClassName);
            [self ej_dismissLoadingWithRequest:request];
            return;
        }
        bizObj = [bizObjectClass mj_objectWithKeyValues:responseObject];
    }

    //转入主线程处理结果
    dispatch_async(dispatch_get_main_queue(), ^{
        //拦截器
        Class interceptorClass = NSClassFromString(self.ej_interceptorClassName);
        //需要判断类是否存在
        if(interceptorClass){
            //如果存在协议名，则拦截
            id<EJHttpResponseInterceptor> httpInterceptorDelegate = [interceptorClass new];
            BOOL result = [httpInterceptorDelegate ej_interceptorResponseObjectWithBizObject:bizObj commonObject:cmnObj];
            if(result){
                //处理UI
                [self ej_dismissLoadingWithRequest:request];
                return;
            }
        }
        //如果拦截器不处理，则处理业务数据状态
        BOOL responseResult = NO;
        NSString *responseErrorMsg = @"";
        if(cmnObj && [cmnObj conformsToProtocol:@protocol(EJHttpResponseDelegate)]){
            responseResult = [(id<EJHttpResponseDelegate>)cmnObj ej_resultFlag];
            responseErrorMsg = [(id<EJHttpResponseDelegate>)cmnObj ej_errorMessage];
            //弹出错误提示
            if(!responseResult){
                [self ej_showErrorMessage:responseErrorMsg withRequest:request response:(id<EJHttpResponseDelegate>)cmnObj];
            }
        } else if(bizObj && [bizObj conformsToProtocol:@protocol(EJHttpResponseDelegate)]){
            responseResult = [(id<EJHttpResponseDelegate>)bizObj ej_resultFlag];
            responseErrorMsg = [(id<EJHttpResponseDelegate>)bizObj ej_errorMessage];
            //弹出错误提示
            if(!responseResult){
                [self ej_showErrorMessage:responseErrorMsg withRequest:request response:(id<EJHttpResponseDelegate>)bizObj];
            }
        }
        //下发请求结果
        if(handler){
            handler(bizObj,responseResult);
        }
        if(cmnHandler){
            cmnHandler(bizObj,cmnObj,responseResult);
        }
        [self ej_dismissLoadingWithRequest:request];
    });
}

- (void)ej_handleFailedResultWithRequest:(id<EJHttpRequestDelegate>)request error:(NSError *)error responseHandler:(EJHttpHandler)handler commonResponseHandler:(EJHttpCommonHandler)cmnHandler{
    //error.localizedFailureReason
    dispatch_async(dispatch_get_main_queue(), ^{
        //错误提示
         if(error.code != NSURLErrorCancelled){
             BOOL status = [self ej_checkNetworkStatus];
             if(status){
                 //有网络，服务器错误，必弹Error
                 [self ej_showErrorMessage:@"请求服务器超时，请稍后再试！" withRequest:request response:nil];
             }
             //Loading符消失
             [self ej_dismissLoadingWithRequest:request];
             //下发请求结果
             if(handler){
                 handler(nil,false);
             }
             if(cmnHandler){
                 cmnHandler(nil,nil,false);
             }
         }
    });
}

#pragma mark - param response 
- (void)ej_handlerResponseParam:(NSDictionary *)param withError:(NSError *)error responseHandler:(EJHttpParamHandler)handler{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isInterceptor = NO;
        if(param){
            //拦截器
            Class interceptorClass = NSClassFromString(self.ej_interceptorClassName);
            //需要判断类是否存在
            if(interceptorClass){
                //如果存在协议名，则拦截
                id<EJHttpResponseInterceptor> httpInterceptorDelegate = [interceptorClass new];
                BOOL result = [httpInterceptorDelegate ej_interceptorResponseParam:param];
                if(result){
                    isInterceptor = YES;
                }
            }
        }
        
        //下发业务
        handler(param,error,isInterceptor);
    });
}

#pragma mark - private methods
//根据是否含有基本URL判断来生成请求队列对象
- (AFHTTPRequestOperationManager *)ej_requestManagerWithURLString:(NSString *)urlString{
    //根据URLString是否基于BaseURL来分配manager
    AFHTTPRequestOperationManager *manager;
    if([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]){
        manager = self.ej_httpManager;
    }
    else{
        manager = self.ej_opManager;
    }
    //通过JSON序列化，并经过GZIP压缩请求流
    if(self.ej_isEnableGzip){
        manager.requestSerializer = [AFgzipRequestSerializer serializerWithSerializer:[AFJSONRequestSerializer serializer]];
    }else{
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
    manager.requestSerializer.timeoutInterval = 20.0;
    [manager.requestSerializer didChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",nil];//设置相应内容类型
    return manager;
}

- (AFHTTPRequestOperationManager *)ej_requestUploadFileManagerWithURLString:(NSString *)urlString{
    //根据URLString是否基于BaseURL来分配manager
    AFHTTPRequestOperationManager *manager = nil;
    if([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]){
        manager = [AFHTTPRequestOperationManager manager];
    }
    else{
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:self.ej_baseURL]];
    }
    //Content-Type必须是“multipart/form-data”，不能设置AFJSONRequestSerier.
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"accept-encoding"];
    manager.requestSerializer.HTTPShouldHandleCookies = NO;
    
    [manager.requestSerializer willChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
    manager.requestSerializer.timeoutInterval = 20.0;
    [manager.requestSerializer didChangeValueForKey:NSStringFromSelector(@selector(timeoutInterval))];
   
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",nil];//设置相应内容类型
    return manager;
}

//整合请求参数
- (NSDictionary *)ej_bodyParamWithRequest:(id<EJHttpRequestDelegate>)request{
    //通过MJ_Extension将对象转化为字典
    NSDictionary *param = [(NSObject *)request mj_keyValues];   //interface data param
    Class cmnObjectClass = NSClassFromString(self.ej_commonRequestClassName);
    //需要判断类是否存在
    if(cmnObjectClass){
        //如果设置有公共请求，则整合
        NSMutableDictionary *bodyParam = [NSMutableDictionary dictionary];
        NSObject *cmnReqObject = [cmnObjectClass new];   //common data param
        NSDictionary *cmnParam = [cmnReqObject mj_keyValues];
        [bodyParam addEntriesFromDictionary:cmnParam];
        bodyParam[self.ej_requestKey] = param;
        return bodyParam;
    }else{
        //直接把业务对象传输
        return param;
    }
}

- (NSDictionary *)ej_bodyParamWithRequestParam:(NSDictionary *)param{
    Class cmnObjectClass = NSClassFromString(self.ej_commonRequestClassName);
    //需要判断类是否存在
    if(cmnObjectClass){
        //如果设置有公共请求，则整合
        NSMutableDictionary *bodyParam = [NSMutableDictionary dictionary];
        NSObject *cmnReqObject = [cmnObjectClass new];   //common data param
        NSDictionary *cmnParam = [cmnReqObject mj_keyValues];
        [bodyParam addEntriesFromDictionary:cmnParam];
        bodyParam[self.ej_requestKey] = param;
        return bodyParam;
    }else{
        //直接把业务对象传输
        return param;
    }
}

/**
 *  检查网络状态
 *  @return BOOL
 */
- (BOOL)ej_checkNetworkStatus{
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    if([reach currentReachabilityStatus]  == NotReachable){
        //无网络
        [self ej_showErrorMessage:@"网络状态不佳，请稍后再试！" withRequest:nil response:nil];
        return NO;
    }
    return YES;
}

#pragma mark - Loading methods
- (void)ej_showLoadingWithRequest:(id<EJHttpRequestDelegate>)request{
    if([request ej_showLoading]){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            Class loadingViewClass = NSClassFromString(self.ej_loadingViewClassName);
            if(loadingViewClass){
                EJLoadingView *loading = [loadingViewClass new];
                loading.ej_loadingMsg = [request ej_loadingMessage];
                [loading ej_showInView:[request ej_loadingContainerView]];
                NSString *hashString = [NSString stringWithFormat:@"%ld",request.hash];
                [self.ej_loadingDict setObject:[request ej_loadingContainerView] forKey:hashString];
            }
        });
    }
}

- (void)ej_dismissLoadingWithRequest:(id<EJHttpRequestDelegate>)request{
    if([request ej_showLoading] && [request ej_endLoadingWhenFinished]){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *hashString = [NSString stringWithFormat:@"%ld",request.hash];
            UIView *containerView = [self.ej_loadingDict objectForKey:hashString];
            EJLoadingView *loading =  [EJLoadingView ej_loadingInContainerView:containerView];
            [loading ej_dismiss];
            [self.ej_loadingDict removeObjectForKey:hashString];
        });
    }
}

#pragma mark - Error methods
- (void)ej_showErrorMessage:(NSString *)errorMsg withRequest:(id<EJHttpRequestDelegate>)request response:(id<EJHttpResponseDelegate>)response{
    if(!request || [request ej_showErrorMessage]){
        Class errorViewClass = NSClassFromString(self.ej_errorViewClassName);
        if(errorViewClass){
            EJErrorView *errorView = [errorViewClass new];
            if(response){
                errorView.ej_errorTitle = [response ej_errorTitle];
                errorView.ej_errorMsg = [response ej_errorMessage];
            }else{
                errorView.ej_errorMsg = errorMsg;
            }
            [errorView ej_show];
        }
    }
}


@end
