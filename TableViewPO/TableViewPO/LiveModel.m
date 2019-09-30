//
//  LiveModel.m
//  TableViewPO
//
//  Created by 陈辉 on 2019/9/29.
//  Copyright © 2019 Nqwl. All rights reserved.
//

#import "LiveModel.h"

@implementation LiveModel
- (void)setRoom_name:(NSString *)room_name {
//    _room_name = [NSString stringWithFormat:@"%@%@%@",room_name,room_name,room_name];
    _room_name = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name];
}
//此处的优化：找的接口里面并没有包含时间戳，所以自己造了个。NSDateFormatter时间转换比较耗时，避免在cell赋值时去创建NSDateFormatter。
- (void)setRoom_id:(NSString *)room_id {
    NSTimeInterval time = 1569813235 + [room_id doubleValue];
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *currentDateStr = [formatter stringFromDate: detaildate];
    _room_id = currentDateStr;
}

@end
