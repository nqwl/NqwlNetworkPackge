//
//  NqwlNetManager.m
//  NetworkPackge
//
//  Created by 亲点 on 2018/9/17.
//  Copyright © 2018年 陈辉. All rights reserved.
//

#import "NqwlNetManager.h"
#import "NqwlNetLocalCache.h"
#import <AFNetworking/AFNetworking.h>

extern NSString *NqwlConvertMD5FromParameter(NSString *url, NSString* method, NSDictionary* paramDict);
static NSString *NqwlNetProcessingQueue = @"com.nqwl.Net";
static NSString *NqwlNetSerialProcessingQueue = @"com.nqwl.SerialNet";

NS_ASSUME_NONNULL_BEGIN
@interface NqwlNetManager (){
    dispatch_queue_t _NqwlNetQueue;
}

@property (nonatomic, strong)NqwlNetLocalCache *cache;
@property (nonatomic, strong) NSMutableArray *batchGroups;//批处理
@property (nonatomic, strong)dispatch_queue_t NqwlNetQueue;
@property (nonatomic, strong)dispatch_queue_t NqwlSerialNetQueue;
@property (nonatomic, strong) AFHTTPSessionManager *afHttpManager;

@end

@implementation NqwlNetManager
- (instancetype)init {
    if (self = [super init]) {
        _NqwlNetQueue = dispatch_queue_create([NqwlNetProcessingQueue UTF8String], DISPATCH_QUEUE_CONCURRENT);
        _NqwlSerialNetQueue = dispatch_queue_create([NqwlNetSerialProcessingQueue UTF8String], DISPATCH_QUEUE_SERIAL);
        _cache = [NqwlNetLocalCache sharedInstance];
        _batchGroups = [NSMutableArray new];
    }
    return self;
}
+ (instancetype)sharedInstance {
    static NqwlNetManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
#pragma mark open get post
- (void)nqwlPostCacheWithUrl:(NSString *)urlString parameters:(NSDictionary *)parameters completionHandlerL:(NqwlRequestCompletionHandler)completionHandler {
    [self nqwlPostWithURLString:urlString parameters:parameters ignoreCache:NO cacheDuration:NetCacheDuration completionHandler:completionHandler];
}

- (void)nqwlGetCacheWithUrl:(NSString *)urlString parameters:(NSDictionary *)parameters completionHandlerL:(NqwlRequestCompletionHandler)completionHandler {
    [self nqwlGetWithURLString:urlString parameters:parameters ignoreCache:NO cacheDuration:NetCacheDuration completionHandler:completionHandler];
}

- (void)nqwlPostNoCacheWithUrl:(NSString *)urlString parameters:(NSDictionary *)parameters completionHandlerL:(NqwlRequestCompletionHandler)completionHandler {
    [self nqwlPostWithURLString:urlString parameters:parameters ignoreCache:YES cacheDuration:0 completionHandler:completionHandler];

}
- (void)nqwlGetNoCacheWithUrl:(NSString *)urlString parameters:(NSDictionary *)parameters completionHandlerL:(NqwlRequestCompletionHandler)completionHandler {
    [self nqwlGetWithURLString:urlString parameters:parameters ignoreCache:YES cacheDuration:0 completionHandler:completionHandler];
}
#pragma mark - post get
- (void)nqwlPostWithURLString:(NSString *)URLString
                 parameters:(NSDictionary * _Nullable)parameters
                ignoreCache:(BOOL)ignoreCache
              cacheDuration:(NSTimeInterval)cacheDuration
          completionHandler:(NqwlRequestCompletionHandler)completionHandler{

    __weak typeof(self) weakSelf = self;
    dispatch_async(_NqwlNetQueue, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf taskWithMethod:@"POST" urlString:URLString parameters:parameters ignoreCache:ignoreCache cacheDuration:cacheDuration completionHandler:completionHandler];
    });
}

- (void)nqwlGetWithURLString:(NSString *)URLString
                parameters:(NSDictionary *)parameters
               ignoreCache:(BOOL)ignoreCache
             cacheDuration:(NSTimeInterval)cacheDuration
         completionHandler:(NqwlRequestCompletionHandler)completionHandler{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_NqwlNetQueue, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf taskWithMethod:@"GET" urlString:URLString parameters:parameters ignoreCache:ignoreCache cacheDuration:cacheDuration completionHandler:completionHandler];
    });
}
#pragma mark afn task resume

/**
 主要的afn发起网络请求

 @param method  请求方法get post
 @param urlStr url地址
 @param parameters 请求参数
 @param ignoreCache 是否忽略缓存，YES忽略，NO不忽略
 @param cacheDuration 缓存时效，同样也是是否缓存的标记
 @param completionHandler 请求结果处理
 */
- (void)taskWithMethod:(NSString*)method
             urlString:(NSString*)urlStr
            parameters:(NSDictionary *)parameters
           ignoreCache:(BOOL)ignoreCache
         cacheDuration:(NSTimeInterval)cacheDuration
     completionHandler:(NqwlRequestCompletionHandler)completionHandler{
    // 1 url+参数 生成唯一码
    NSString *fileKeyFromUrl = NqwlConvertMD5FromParameter(urlStr, method, parameters);
    __weak typeof(self) weakSelf = self;
    // 2 缓存+失效 判断是否有有效缓存
    if (!ignoreCache&&[self.cache checkIfShouldUseCacheWithCacheDuration:cacheDuration cacheKey:fileKeyFromUrl]) {
        NSMutableDictionary *localCache = [NSMutableDictionary dictionary];
        NSDictionary *cacheDict = [self.cache searchCacheWithUrl:fileKeyFromUrl];
        [localCache setDictionary:cacheDict];
        if (cacheDict) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.exceptionBlock) {
                    weakSelf.exceptionBlock(nil,localCache);
                }
                NSLog(@"获取缓存成功");
                completionHandler(nil,YES,localCache);
            });
            return;
        }
    }

    NqwlRequestCompletionHandler newCompletionBlock = ^( NSError* error,  BOOL isCache, NSDictionary* result){
        //5.1处理缓存  ⚠️参数ignoreCache(网络task发起前，是否从本来缓存中获取数据)  cacheDuration(网络task结束后，是否对网络数据缓存)
        if (result) {
            result = [NSMutableDictionary dictionaryWithDictionary:result];
            if (cacheDuration > 0) {// 缓存时效(即缓存时间)大于0
                if (result) {
                    if (weakSelf.cacheConditionBlock) {
                        if (weakSelf.cacheConditionBlock(result)) {
                            [weakSelf.cache saveCacheData:result forKey:fileKeyFromUrl];
                        }
                    }else{
                        [weakSelf.cache saveCacheData:result forKey:fileKeyFromUrl];
                    }
                }
            }

            //5.2回掉
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.exceptionBlock) {
                    weakSelf.exceptionBlock(error, (NSMutableDictionary*)result);
                }
                completionHandler(error, NO, result);
            });
        }else {
            result = [NSMutableDictionary dictionaryWithDictionary:result];
            completionHandler(error, NO, result);
            NSLog(@"异常不做缓存处理");
        }
    };

    //3  发起AF网络任务
    NSURLSessionTask *task = nil;
    if ([method isEqualToString:@"GET"]) {

        task = [self.afHttpManager  GET:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            /*
             4 处理数据 （处理数据的时候，需要处理下载的网络数据是否要缓存）
             这里可以直接使用 completionHandler，如果这样，网络返回的数据没有做缓存处理机制
             */
            newCompletionBlock(nil,NO, responseObject);

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

            newCompletionBlock(error,NO, nil);;
        }];

    }else{

        task = [self.afHttpManager POST:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            newCompletionBlock(nil,NO, responseObject);

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

            newCompletionBlock(error,NO, nil);
        }];

    }

    [task resume];
}
- (AFHTTPSessionManager*)afHttpManager {
    if (!_afHttpManager) {
        //由单例对象强引用AFHTTPSessionManager保证AFHTTPSessionManager唯一，避免内存泄漏
        AFHTTPSessionManager *afManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.validatesDomainName = NO;
        securityPolicy.allowInvalidCertificates = YES;
        afManager.securityPolicy = securityPolicy;
        _afHttpManager = afManager;
    }
    return _afHttpManager;
}

- (NqwlNetRequestInfo*)nqwlNetRequestWithURLStr:(NSString *)URLString method:(NSString*)method parameters:(NSDictionary *)parameters ignoreCache:(BOOL)ignoreCache cacheDuration:(NSTimeInterval)cacheDuration completionHandler:(NqwlRequestCompletionHandler)completionHandler{

    NqwlNetRequestInfo *nqwlNetRequestInfo = [NqwlNetRequestInfo new];
    nqwlNetRequestInfo.urlStr = URLString;
    nqwlNetRequestInfo.method = method;
    nqwlNetRequestInfo.parameters = parameters;
    nqwlNetRequestInfo.ignoreCache = ignoreCache;
    nqwlNetRequestInfo.cacheDuration = cacheDuration;
    nqwlNetRequestInfo.completionBlock = completionHandler;
    return nqwlNetRequestInfo;
}
- (void)nqwlBatchOfRequestOperations:(NSArray<NqwlNetRequestInfo *> *)tasks
                     progressBlock:(void (^)(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks))progressBlock
                   completionBlock:(netSuccessbatchBlock)completionBlock{

    /*
     使用 dispatch_group_t 技术点
     多少个任务  对group添加多少个 空任务数(dispatch_group_enter)
     任务完成后  对group的任务数-1 操作(dispatch_group_leave);
     当group的任务数为0了，就会执行dispatch_group_notify的block块操作，即所有的网络任务请求完了。

     可以看作是一个信号量的处理， 刚开始有3个信号量 sem = 3， 当 sem = 0时 处理
     */
    __weak typeof(self) weakSelf = self;
    dispatch_async(_NqwlNetQueue, ^{

        __block dispatch_group_t group = dispatch_group_create();
        [weakSelf.batchGroups addObject:group];

        __block NSInteger finishedTasksCount = 0;
        __block NSInteger totalNumberOfTasks = tasks.count;

        [tasks enumerateObjectsUsingBlock:^(NqwlNetRequestInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            if (obj) {

                // 网络任务启动前dispatch_group_enter
                dispatch_group_enter(group);

                NqwlRequestCompletionHandler newCompletionBlock = ^( NSError* error,  BOOL isCache, NSDictionary* result){

                    progressBlock(finishedTasksCount, totalNumberOfTasks);
                    if (obj.completionBlock) {
                        obj.completionBlock(error, isCache, result);
                    }
                    // 网络任务结束后dispatch_group_enter
                    dispatch_group_leave(group);

                };
                if ([obj.method isEqual:@"POST"]) {

                    [[NqwlNetManager sharedInstance] nqwlPostWithURLString:obj.urlStr parameters:obj.parameters ignoreCache:obj.ignoreCache cacheDuration:obj.cacheDuration completionHandler:newCompletionBlock];

                }else{

                    [[NqwlNetManager sharedInstance] nqwlGetWithURLString:obj.urlStr parameters:obj.parameters ignoreCache:obj.ignoreCache cacheDuration:obj.cacheDuration completionHandler:newCompletionBlock];
                }

            }

        }];

        //监听
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [weakSelf.batchGroups removeObject:group];
            if (completionBlock) {
                completionBlock(tasks);
            }
        });
    });
}

@end



NS_ASSUME_NONNULL_END
