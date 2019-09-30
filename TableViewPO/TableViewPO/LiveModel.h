//
//  LiveModel.h
//  TableViewPO
//
//  Created by 陈辉 on 2019/9/29.
//  Copyright © 2019 Nqwl. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LiveModel : NSObject

@property (nonatomic, copy) NSString *owner_uid;
@property (nonatomic, copy) NSString *online;
@property (nonatomic, assign) NSInteger hn;
@property (nonatomic, copy) NSString *room_name;
@property (nonatomic, copy) NSString *room_id;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *room_src;
@property (nonatomic, assign) NSInteger cellHeight;

@end

