//
//  LiveViewModel.h
//  TableViewPO
//
//  Created by 陈辉 on 2019/9/29.
//  Copyright © 2019 Nqwl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LiveModel.h"
@interface LiveViewModel : NSObject
@property (nonatomic, strong) NSMutableArray *dataArray;

- (void)requestLive:(NSInteger)page dataSuccess:(void(^)(void))successBlock failBlock:(void(^)(NSError *error))failBlock;
- (void)reload:(UITableView *)tableView;
- (LiveModel *)liveModelForRow:(NSInteger)row;
- (CGFloat)liveHeightForRow:(NSInteger)row;
- (void)scrollToBottom:(UITableView *)tableView;
@end

