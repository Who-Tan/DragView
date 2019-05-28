//
//  CustomChannelViewController.h
//  SportsAppTest
//
//  Created by JiaJunTan on 2018/12/11.
//  Copyright © 2018年 JiaJunTan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelModel.h"

@interface CustomChannelViewController : UIViewController

@property(nonatomic,strong)NSMutableArray *addedChannels;

@property(nonatomic,strong)NSArray *hotChannels;
@property(nonatomic,strong)NSArray *pcChannels;
@property(nonatomic,strong)NSArray *mobileChannels;

@end


//@interface ChannelView : UIView
//
//@property(nonatomic,strong)UIButton *deleteBtn;
//@property(nonatomic,strong)NSString *channelTitle;
//@property(nonatomic,assign)BOOL showDeleteBtn;
//@end


@protocol ISegmentView<NSObject>
- (void)didSelectSegmentIndex:(NSInteger)index;
@end

@interface SegmentView : UIView
@property(nonatomic,weak)id<ISegmentView> delegate;
@property(nonatomic,strong)NSArray *titleArr;
@property(nonatomic,strong)UIView *btnHoldV;
@property(nonatomic,strong)UIView *selectLine;
@end


@interface CoverView : UIView
@property(nonatomic,strong)UIImageView *imgV;
@property(nonatomic,strong)UILabel *titleL;
@property(nonatomic,strong)UIButton *selectBtn;
@property(nonatomic,assign)BOOL isEdit;
@end


@protocol CollecDragSortDelegate <NSObject>
- (void)dargSortCellGestureAction:(UIGestureRecognizer *)gestureRecognizer;
@end

@interface SortChannelCollecCell : UICollectionViewCell
@property(nonatomic,weak)id<CollecDragSortDelegate> delegate;
@property(nonatomic,strong)UILabel *textLabel;
@property(nonatomic,strong)UIButton *deleteBtn;
@property(nonatomic,assign)BOOL showDeleteBtn;

@end


@protocol IFreeChannelView<NSObject>
- (void)didClickFreeChannel:(ChannelModel *)model;
@end

@interface FreeChannelView : UIView
@property(nonatomic,weak)id<IFreeChannelView> delegate;
@property(nonatomic,strong)UICollectionView *freeChannelCV;
@property(nonatomic,strong)NSArray *modelsArr;
@property(nonatomic,assign)BOOL isEdit;
@end
