//
//  LiveViewModel.m
//  TableViewPO
//
//  Created by 陈辉 on 2019/9/29.
//  Copyright © 2019 Nqwl. All rights reserved.
//

#import "LiveViewModel.h"
#import "NqwlNetManager.h"
#import "MJExtension.h"
#define kPageSize 10

@interface LiveViewModel()
@property (nonatomic, strong) NSMutableArray *refreshIndexPaths;
//search/topics
@end
@implementation LiveViewModel

- (void)requestLive:(NSInteger)page dataSuccess:(void(^)(void))successBlock failBlock:(void (^)(NSError *))failBlock {
    __weak __typeof(self)weakSelf = self;
    [[NqwlNetManager sharedInstance] nqwlGetCacheWithUrl:@"http://open.douyucdn.cn/api/RoomApi/live" parameters:@{@"offset":@(page),@"limit":@(kPageSize)} completionHandlerL:^(NSError * _Nullable error, BOOL isCache, NSDictionary * _Nullable result) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!error) {
            NSMutableArray *array = [LiveModel mj_objectArrayWithKeyValuesArray:result[@"data"]];
            [strongSelf.refreshIndexPaths removeAllObjects];
            if (page == 0) {
                for (int i = 0; i<array.count; i++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [strongSelf.refreshIndexPaths addObject:indexPath];
                }
                strongSelf.dataArray = array;
            }else {
                for (int i = 0; i<array.count; i++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:strongSelf.dataArray.count+i inSection:0];
                    [strongSelf.refreshIndexPaths addObject:indexPath];
                }
                [strongSelf.dataArray addObjectsFromArray:array];
            }
            successBlock();
        }else {
            failBlock(error);
        }
    }];
}
- (LiveModel *)liveModelForRow:(NSInteger)row {
    return self.dataArray[row];
}
- (void)reload:(UITableView *)tableView {
    if (self.refreshIndexPaths.count>0&&self.dataArray.count>kPageSize) {
        //self.dataArray.count>10为了防止下拉刷新的时候，tableview已经存在cell，仍然往指定的cell插入cell造成崩溃的问题
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:self.refreshIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }else {
        [tableView reloadData];
    }
}
- (CGFloat)liveHeightForRow:(NSInteger)row {
    LiveModel *live = self.dataArray[row];
    if (live.cellHeight>0) {//避免以计算高度的cell，还重复执行文字高度计算的操作
        return live.cellHeight;
    }
    CGFloat nameHeight = [self getString:live.room_name lineSpacing:1 font:[UIFont systemFontOfSize:15] width:[UIScreen mainScreen].bounds.size.width-30];
    CGFloat imgHeight = ([UIScreen mainScreen].bounds.size.width - 20)*0.6;
    live.cellHeight = 10 + imgHeight + 5 + nameHeight + 5;
    return live.cellHeight;
}
- (void)scrollToBottom:(UITableView *)tableView {
    if (self.dataArray.count>1) {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0];
        [tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
    }else {
        NSAssert(YES, @"scrollToBottom 没有数据");
    }
}
- (CGFloat)getStringHeightWithText:(NSString *)text font:(UIFont *)font viewWidth:(CGFloat)width {
    // 设置文字属性 要和label的一致
    NSDictionary *attrs = @{NSFontAttributeName :font};
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    // 计算文字占据的宽高
    CGSize size = [text boundingRectWithSize:maxSize options:options attributes:attrs context:nil].size;
    // 当你是把获得的高度来布局控件的View的高度的时候.size转化为ceilf(size.height)。
    return  ceilf(size.height);
}
- (CGFloat)getString:(NSString *)string lineSpacing:(CGFloat)lineSpacing font:(UIFont*)font width:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = lineSpacing;
    NSDictionary *dic = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle };
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return  ceilf(size.height);
}
- (NSMutableArray *)refreshIndexPaths {
    if (!_refreshIndexPaths) {
        _refreshIndexPaths = [NSMutableArray arrayWithCapacity:10];
    }
    return _refreshIndexPaths;
}
@end
