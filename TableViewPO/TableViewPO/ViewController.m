//
//  ViewController.m
//  TableViewPO
//
//  Created by 陈辉 on 2019/9/29.
//  Copyright © 2019 Nqwl. All rights reserved.
//


#import "ViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "Masonry.h"
#import "NomalViewController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *contenTB;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"关于TableView的性能优化";
    [self.view addSubview:self.contenTB];
    [self.contenTB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.layer.masksToBounds = YES;
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NomalViewController *vc = [NomalViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithArray:@[
                                                      @"页面极致优化",
                                                      ]];
    }
    return _dataArray;
}
- (UITableView *)contenTB {
    if (!_contenTB) {
        _contenTB = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
        [_contenTB registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        _contenTB.dataSource = self;
        _contenTB.delegate = self;
    }
    return _contenTB;
}
@end
