//
//  LiveCell.m
//  TableViewPO
//
//  Created by 陈辉 on 2019/9/29.
//  Copyright © 2019 Nqwl. All rights reserved.
//

#import "LiveCell.h"
#import "Masonry.h"
#import <SDWebImage/SDWebImage.h>
@interface LiveCell()

@property (nonatomic, strong) UIImageView *headIV;
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, strong) UILabel *roomIdLabel;
@property (nonatomic, strong) UILabel *watchNumLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end
@implementation LiveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}
- (void)createUI {
    [self.contentView addSubview:self.headIV];
    [self.contentView addSubview:self.roomNameLabel];
    [self.contentView addSubview:self.timeLabel];
//    [self.contentView addSubview:self.nickNameLabel];
//    [self.contentView addSubview:self.roomIdLabel];
//    [self.contentView addSubview:self.watchNumLabel];
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(self.headIV.mas_width).multipliedBy(0.6);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.mas_equalTo(self.headIV);
    }];
    [self.roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headIV.mas_left).mas_offset(5);
        make.top.mas_equalTo(self.headIV.mas_bottom).mas_offset(5);
        make.right.mas_equalTo(self.headIV.mas_right).mas_offset(-5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-5);
    }];
}
- (void)setLive:(LiveModel *)live {
    _live = live;
    [self.headIV sd_setImageWithURL:[NSURL URLWithString:live.room_src] placeholderImage:[UIImage imageNamed:@"live_default"]];
    self.roomNameLabel.text = live.room_name;
    self.timeLabel.text = live.room_id;
}
- (UIImageView *)headIV {
    if (!_headIV) {
        _headIV = [[UIImageView alloc] init];
    }
    return _headIV;
}
- (UILabel *)roomIdLabel {
    if (!_roomIdLabel) {
        _roomIdLabel = [[UILabel alloc] init];
    }
    return _roomIdLabel;
}
- (UILabel *)roomNameLabel {
    if (!_roomNameLabel) {
        _roomNameLabel = [[UILabel alloc] init];
        _roomNameLabel.font = [UIFont systemFontOfSize:15];
        _roomNameLabel.layer.masksToBounds = YES;
        _roomNameLabel.backgroundColor = [UIColor whiteColor];
        _roomNameLabel.numberOfLines = 0;
    }
    return _roomNameLabel;
}
- (UILabel *)watchNumLabel {
    if (!_watchNumLabel) {
        _watchNumLabel = [[UILabel alloc] init];
    }
    return _watchNumLabel;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.layer.masksToBounds = YES;
        _timeLabel.backgroundColor = [UIColor whiteColor];
    }
    return _timeLabel;
}
- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
    }
    return _nickNameLabel;
}
@end
