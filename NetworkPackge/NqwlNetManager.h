//
//  NqwlNetManager.h
//  NetworkPackge
//
//  Created by 亲点 on 2018/9/17.
//  Copyright © 2018年 陈辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NqwlMD5DataConvert.h"
#import "NqwlNetRequestInfo.h"
#define NetCacheDuration 60*5

NS_ASSUME_NONNULL_BEGIN
typedef void (^NqwlRequestCompletionHandler)( NSError* _Nullable error,  BOOL isCache, NSDictionary* _Nullable result);

@interface NqwlNetManager : NSObject {
    dispatch_queue_t _nqwl_NetQueue;
}
+ (nonnull instancetype)sharedInstance;

/**
 外部添加异常处理 （根据服务器返回的数据，统一处理，如处理登录实效），默认不做处理
 */
@property (nonatomic, copy)NqwlRequestCompletionAddExcepetionHanle exceptionBlock;
// 返回NO， cache不保存
@property (nonatomic, copy)NqwlRequestCompletionAddCacheCondition cacheConditionBlock;

- (void)nqwlPostCacheWithUrl:(NSString *)urlString parameters:(NSDictionary *)parameters completionHandlerL:(NqwlRequestCompletionHandler)completionHandler;
- (void)nqwlGetCacheWithUrl:(NSString *)urlString parameters:(NSDictionary *)parameters completionHandlerL:(NqwlRequestCompletionHandler)completionHandler;
- (void)nqwlPostNoCacheWithUrl:(NSString *)urlString parameters:(NSDictionary *)parameters completionHandlerL:(NqwlRequestCompletionHandler)completionHandler;
- (void)nqwlGetNoCacheWithUrl:(NSString *)urlString parameters:(NSDictionary *)parameters completionHandlerL:(NqwlRequestCompletionHandler)completionHandler;

//对象化网络请求，将每一个网络请求保存下来
- (NqwlNetRequestInfo*)nqwlNetRequestWithURLStr:(NSString *)URLString method:(NSString*)method parameters:(NSDictionary *)parameters ignoreCache:(BOOL)ignoreCache cacheDuration:(NSTimeInterval)cacheDuration completionHandler:(NqwlRequestCompletionHandler)completionHandler;
- (void)nqwlBatchOfRequestOperations:(NSArray<NqwlNetRequestInfo *> *)tasks progressBlock:(void (^)(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks))progressBlock completionBlock:(netSuccessbatchBlock)completionBlock;

@end
NS_ASSUME_NONNULL_END
