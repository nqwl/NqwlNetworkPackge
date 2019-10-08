# TableView的性能优化
>  有遇到性能瓶颈的地方可以issue，欢迎交流。

- 1、网络框架的封装
    - 可控的定时网络数据本地缓存，避免重复的网络请求+统一异常处理机制（改进方向：将每一个请求操作对象化）
- 2、关于Cell高度计算的细节优化(并没有用到self-sizing cell的方式计算高度)
    - 内存缓存Cell高度+根据Cell高度标识减少高度计算次数(改进方向：对于包含多个高度计算的页面，可以考虑将控件的位置缓存起来；对于复杂图文混排的页面，考虑使用CGContext进行处理)
```
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
```
- 3、UItableView刷新优化
    - 按需刷新(注意数据与Cell数量的统一,代码有细节处理)
```
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
```
- 4、关于后台数据与需展示的数据存在需要转换的情况处理(时间转换，数据解密等处理)
    - 在自定义model中，重写待转换字段的setter方法，在此方法中进行数据转换。这样的处理，可以将数据转换的操作从页面展示前，提前到数据创建时，一定程度上避免页面刷新卡顿的情况。
```
#import "LiveModel.h"
static NSDateFormatter *formatter;//NSDateFormatter创建操作比较耗时，所以设置静态变量，重复利用
@implementation LiveModel

- (void)setRoom_name:(NSString *)room_name {
//    _room_name = [NSString stringWithFormat:@"%@%@%@",room_name,room_name,room_name];
    _room_name = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name,room_name];
}
//此处的优化：找的接口里面并没有包含时间戳，所以自己造了个。NSDateFormatter时间转换比较耗时，避免在cell赋值时去创建NSDateFormatter。若存在加密数据，转换亦是如此。
- (void)setRoom_id:(NSString *)room_id {
    NSTimeInterval time = 1569813235 + [room_id doubleValue];
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
    }
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *currentDateStr = [formatter stringFromDate: detaildate];
    _room_id = currentDateStr;
}

@end
```
- 5、文字高度计算的一些处理
    - 文字高度计算记得考虑行间距
```
- (CGFloat)getString:(NSString *)string lineSpacing:(CGFloat)lineSpacing font:(UIFont*)font width:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = lineSpacing;
    NSDictionary *dic = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle };
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return  ceilf(size.height);
}
```
