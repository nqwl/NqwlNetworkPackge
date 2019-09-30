//
//  AppDelegate+NetCache.m
//  ExamProject
//
//  Created by ksw on 2017/10/13.
//  Copyright © 2017年 SunYong. All rights reserved.
//

#import "AppDelegate+NetCache.h"
#import "NqwlNetManager.h"


@implementation AppDelegate (NetCache)

// 配置缓存条件
- (void)configNetCacheCondition{
    
    // return YES 缓存， NO不缓存
    [NqwlNetManager sharedInstance].cacheConditionBlock = ^BOOL(NSDictionary * _Nonnull result) {
     
        if([result isKindOfClass:[NSDictionary class]]){
            
            if([[result objectForKey:@"error"] intValue] == 0){
                
                return YES;
            }
        }
        
        return NO;
    };
    
}

@end
