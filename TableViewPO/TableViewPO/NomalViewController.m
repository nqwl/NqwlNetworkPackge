//
//  NomalViewController.m
//  TableViewPO
//
//  Created by 陈辉 on 2019/9/29.
//  Copyright © 2019 Nqwl. All rights reserved.
//
/*
 关于UITableView优化思路
 1、避免主线程阻塞
 2、避免频繁对象创建
 3、减少对象属性的赋值
 4、异步绘制
 5、简化视图结构
 6、减少离屏渲染

    优化方案：数据缓存处理 + 预处理耗时对象的创建(字典转模型的时候提前计算出时间，避免阻塞主线程) + 内存缓存cell高度 + 按需加载cell
 */

#import "NomalViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "Masonry.h"
#import "LiveViewModel.h"
#import "LiveCell.h"

@interface NomalViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *contenTB;
@property (nonatomic, strong) LiveViewModel *liveViewModel;
@property (nonatomic, assign) NSInteger page;
@end

@implementation NomalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 0;
    self.navigationItem.title = @"TableView性能优化";
    [self.view addSubview:self.contenTB];
    [self.contenTB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"压测" style:(UIBarButtonItemStylePlain) target:self action:@selector(pressureTestClick)];
    [self loadData];
}
- (void)pressureTestClick {
    __block int timeout = 30;
    __weak __typeof(self)weakSelf = self;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (timeout<0) {
            dispatch_source_cancel(timer);
        }else {
            timeout = timeout - 0.1;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.liveViewModel scrollToBottom:strongSelf.contenTB];
            });
        }
    });
    dispatch_resume(timer);
}
- (void)loadData {
    __weak __typeof(self)weakSelf = self;
    [self.liveViewModel requestLive:self.page dataSuccess:^(void) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.contenTB.mj_header endRefreshing];
        [strongSelf.contenTB.mj_footer endRefreshing];
        [strongSelf.liveViewModel reload:strongSelf.contenTB];
    } failBlock:^(NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.contenTB.mj_header endRefreshing];
        [strongSelf.contenTB.mj_footer endRefreshing];
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveCell" forIndexPath:indexPath];
    cell.live = [self.liveViewModel liveModelForRow:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.liveViewModel.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.liveViewModel liveHeightForRow:indexPath.row];
}
- (UITableView *)contenTB {
    if (!_contenTB) {
        _contenTB = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
        [_contenTB registerClass:[LiveCell class] forCellReuseIdentifier:@"LiveCell"];
        _contenTB.dataSource = self;
        _contenTB.delegate = self;
        //处理iOS11之后，reloadCell时出现cell闪的情况
        _contenTB.estimatedRowHeight = 0;
        _contenTB.estimatedSectionHeaderHeight = 0;
        _contenTB.estimatedSectionFooterHeight = 0;

        __weak __typeof(self)weakSelf = self;
        _contenTB.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.page = 0;
            [strongSelf loadData];
        }];

        _contenTB.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.page ++;
            [strongSelf loadData];
        }];
    }
    return _contenTB;
}

- (LiveViewModel *)liveViewModel {
    if (!_liveViewModel) {
        _liveViewModel = [LiveViewModel new];
    }
    return _liveViewModel;
}
@end

