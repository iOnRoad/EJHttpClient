//
//  EJHttpClient.h
//  EJDemo
//
//  Created by iOnRoad on 16/4/26.
//  Copyright © 2016年 iOnRoad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EJHttpRequestDelegate.h"
#import "EJHttpResponseInterceptor.h"
#import "EJHttpResponseDelegate.h"
#import "EJLoadingView.h"
#import "EJErrorView.h"

//请求回调
//仅包含响应内容对象的回调
typedef void (^EJHttpHandler)(id respObject,BOOL success);
//包含通用响应内容对象的回调
typedef void (^EJHttpCommonHandler)(id respObject,BOOL success,id cmnRespObject);
//以字典方式展现回调，用于动态返回字段的情形
typedef void (^EJHttpParamHandler)(NSDictionary *param,NSError *error);
//上传图片回调bytes本次传输多少，totalBytes总共传输了多少，totalBytesExpected需要上传的文件大小是多少
typedef void (^EJHttpProgressHandler)(NSUInteger bytes, long long totalBytes, long long totalBytesExpected);

//请求方式
typedef NS_ENUM(NSInteger, EJHttpRequestMethod) {
    GET = 0,
    POST,
};

@interface EJHttpClient : NSObject

//单例
+ (instancetype)shared;

//注册基本信息
- (void)ej_registerBaseURL:(NSString *)urlString;      //基本URL
- (void)ej_registerInterceptorClassName:(NSString *)interceptorClassName;      //需要需要拦截，则注册该方法
- (void)ej_registerCommonRequestClassName:(NSString *)commonRequestClassName bizRequestKey:(NSString *)requestKey;     //如果有通用请求数据，则需要注册通用请求类对象
- (void)ej_registerCommonResponseClassName:(NSString *)commonResponseClassName bizResponseKey:(NSString *)responseKey;     //如果有通用响应类数据，则需要注册通用响应类对象
- (void)ej_registerLoadingViewClassName:(NSString *)loadingViewClassName errorViewClassName:(NSString *)errorViewClassName;

//启用Gzip序列化，默认Json
- (void)ej_enableGzipRequestSerializer;
//检查网络状态
- (BOOL)ej_checkNetworkStatus;


/**
 *  快捷请求方法1
 *  @param request 请求参数实体
 *  @param handler Block，包含“响应数据实体”、“是否正常获取数据”
 */
- (void)ej_requestPostParamObject:(id <EJHttpRequestDelegate>)request responseHandler:(EJHttpHandler)handler;
- (void)ej_requestParamObject:(id <EJHttpRequestDelegate>)request method:(EJHttpRequestMethod)method responseHandler:(EJHttpHandler)handler;

/**
 *  快捷请求方法2
 *  @param request 请求参数实体
 *  @param handler Block，包含“响应数据实体”、“是否正常获取数据”、“基本通用数据”
 */
- (void)ej_requestPostParamObject:(id <EJHttpRequestDelegate>)request responseCommonHandler:(EJHttpCommonHandler)commonHandler;
- (void)ej_requestParamObject:(id <EJHttpRequestDelegate>)request method:(EJHttpRequestMethod)method responseCommonHandler:(EJHttpCommonHandler)commonHandler;


//**** 加载符和错误显示,以及拦截器 需单独实现 *******
/**
 *  通用请求实现方法，请求参数以字典传递，接收参数以字典接收
 *  @param URLString     接口URL全屏或者半拼（半拼会追加BaseURL）
 *  @param method        GET、POST
 *  @param request       请求参数实体
 *  @param handler       包含“响应数据实体”、“是否正常获取数据”，如果使用该block，把commonHandler参数置为nil
 *  @param commonHandler 包含“响应数据实体”、“是否正常获取数据”、“基本通用数据”，如果使用该block，则把responseHandler参数置为nil
 */
- (void)ej_requestWithURLString:(NSString *)urlString method:(EJHttpRequestMethod)method param:(NSDictionary *)param responseHandler:(EJHttpParamHandler)handler;

/**
 *  上传图片二进制，并获取图片资源
 *
 *  @param URLString       URL
 *  @param param           param
 *  @param name            图片对应的KEY
 *  @param imageData       图片的二进制流
 *  @param imageName       图片文件名
 *  @param miniType        图片后缀名
 *  @param handler         请求回调
 *  @param progressHandler 上传进度
 */
//**** 加载符和错误显示，以及拦截器 需单独实现 *******
- (void)ej_requestUploadFileWithURLString:(NSString *)urlString param:(NSDictionary *)param name:(NSString *)name fileData:(NSData *)fileData fileName:(NSString *)fileName mimeType:(NSString *)miniType responseHandler:(EJHttpParamHandler)handler progress:(EJHttpProgressHandler)progressHandler;

@end
