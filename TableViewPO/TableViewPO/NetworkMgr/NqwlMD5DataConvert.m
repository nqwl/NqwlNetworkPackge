//
//  NqwlMD5DataConvert.m
//  WKWevView
//
//  Created by 亲点 on 2018/9/14.
//  Copyright © 2018年 陈辉. All rights reserved.
//

#import "NqwlMD5DataConvert.h"
#import <CommonCrypto/CommonDigest.h>

static NSString * NqwlConvertMD5FromString(NSString *str){

    if(str.length == 0){
        return nil;
    }

    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (unsigned int)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
    {
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];
}


static NSString *NqwlNetCacheVersion(){

    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


/**
 对传入的参数一起进行MD5加密，并生成该请求的缓存文件名

 @param url url地址
 @param method 请求方式
 @param paramDict 请求参数
 @return md5结果
 */
NSString *NqwlConvertMD5FromParameter(NSString *url, NSString* method, NSDictionary* paramDict){

    NSString *requestInfo = [NSString stringWithFormat:@"Method:%@ Url:%@ Argument:%@ AppVersion:%@ ",
                             method,
                             url,
                             paramDict,
                             NqwlNetCacheVersion()];

    return NqwlConvertMD5FromString(requestInfo);
}



@implementation NqwlMD5DataConvert


@end
