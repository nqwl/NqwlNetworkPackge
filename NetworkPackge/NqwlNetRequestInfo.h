//
//  NqwlNetRequestInfo.h
//  NetworkPackge
//
//  Created by 亲点 on 2018/9/17.
//  Copyright © 2018年 陈辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NqwlRequestCompletionHandler)( NSError* _Nullable error,  BOOL isCache, NSDictionary* _Nullable result);
typedef BOOL (^NqwlRequestCompletionAddCacheCondition)(NSDictionary *result);

typedef void (^netSuccessbatchBlock)(NSArray *operationAry);


@interface NqwlNetRequestInfo : NSObject

@property(nonatomic, strong)NSString *urlStr;
@property(nonatomic, strong)NSString *method;
@property(nonatomic, strong)NSDictionary *parameters;
@property(nonatomic, assign)BOOL ignoreCache;
@property(nonatomic, assign)NSTimeInterval cacheDuration;
@property(nonatomic, copy)NqwlRequestCompletionHandler completionBlock;


typedef void (^NqwlRequestCompletionAddExcepetionHanle)(NSError* _Nullable errror,  NSMutableDictionary* result);

@end

NS_ASSUME_NONNULL_END
