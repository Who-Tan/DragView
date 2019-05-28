//
//  CustomChannelViewController.m
//  SportsAppTest
//
//  Created by JiaJunTan on 2018/12/11.
//  Copyright © 2018年 JiaJunTan. All rights reserved.
//

#import "CustomChannelViewController.h"
#import "MTCollectionViewLayout.h"


static const CGFloat side_gap = 20;
static const CGFloat vertical_gap = 20;
static const CGFloat channelItem_H = 35.5;

@interface CustomChannelViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,IMTCollectionViewLayoutDelegate,CollecDragSortDelegate>{
    UIScrollView *scrollView;
    UIView *navView;
    UIButton *manageBtn;
    
    UIView *addedChannelsView;
    UIView *channelsHoldView;

    NSMutableArray *channelsRectArr;

}

@property (strong, nonatomic) UICollectionView *collectionV;
@property (nonatomic,strong) UIView *snapshotView; //截屏得到的view
@property (nonatomic,weak) SortChannelCollecCell *originalCell;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) NSIndexPath *nextIndexPath;
@property (nonatomic,assign) BOOL isEditing;

@end

@implementation CustomChannelViewController

- (instancetype)init{
    if (self == [super init]){
        _addedChannels = [NSMutableArray arrayWithArray:@[@"我",@"遇见",@"三人游",@"追赶时间",@"我要的世界",@"像我这样的人",@"夜空中最亮的星",@"You Took My Heart Away",@"Nothing's Gonna Change My Love For You,",@"Someone Like You",@"Better Man"]];
        
        _isEditing = false;
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(addedChannelsView.frame));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor whiteColor];
    [self createNavView];
    [self createMainView];
    
    [self countChannelsViewHeight];
    [self createDynamicCV];
    
}

- (void)createNavView{
    CGFloat iPhonex_topY = 0;
    if (iPhoneX){
        iPhonex_topY = 24;
    }
    navView = [[UIView alloc] initWithFrame:CGRectMake(0, iPhonex_topY, APPW, STATUSH+NAVH)];
    navView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navView];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 35, 20, 17)];
    [backBtn setImage:[UIImage imageNamed:@"blackBack"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    UILabel *titleLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(navView.frame)-60, CGRectGetMidY(backBtn.frame)-9, 120, 18)];
    titleLb.text = @"拖拽排序吧！";
    titleLb.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size: 18];
    CGAffineTransform matrix = CGAffineTransformMake(1,0,tanf(-15 * (CGFloat)M_PI /180),1,0, 0);
    titleLb.transform = matrix;
    [navView addSubview:titleLb];
    
    manageBtn = [[UIButton alloc] initWithFrame:CGRectMake(APPW-60, CGRectGetMidY(backBtn.frame)-10, 60, 20)];
    [manageBtn setTitle:@"管理" forState:UIControlStateNormal];
    [manageBtn setTitle:@"完成" forState:UIControlStateSelected];
    [manageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    manageBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    manageBtn.titleLabel.contentMode = UIViewContentModeLeft;
    [manageBtn addTarget:self action:@selector(manageAction:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:manageBtn];
    
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(navView.frame)-0.5, APPW, 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
    [navView addSubview:bottomLine];
}

- (void)createMainView{
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navView.frame), APPW, APPH-48)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    
    //已添加频道
    addedChannelsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APPW, 48)];
    [scrollView addSubview:addedChannelsView];
    
    UILabel *addedTitleLB = [[UILabel alloc] initWithFrame:CGRectMake(22, 20, 95, 18)];
    addedTitleLB.text = @"这是一些歌";
    addedTitleLB.font = [UIFont boldSystemFontOfSize:18];
    [addedChannelsView addSubview:addedTitleLB];
    
//    点击管理或者长按，编辑排序
    UILabel *subTitleLB = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addedTitleLB.frame), CGRectGetMaxY(addedTitleLB.frame)-13, 150, 11)];
    subTitleLB.text = @"点击管理或者长按，编辑排序";
    subTitleLB.font = [UIFont systemFontOfSize:10];
    [subTitleLB setTextColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]];
    [addedChannelsView addSubview:subTitleLB];

    channelsHoldView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(addedTitleLB.frame)+10, APPW, 0)];
    [addedChannelsView addSubview:channelsHoldView];
}

//MARK: ------- 已添加频道 data
- (void)createDynamicCV{
 
    MTCollectionViewLayout *layout = [[MTCollectionViewLayout alloc]init];
    layout.MaximumSpacing = 10.0;
    layout.minimumLineSpacingForSection = 20.0;
    layout.sectionEdgeInsets = UIEdgeInsetsMake(10,20,10,20);
    layout.delegate = self;
    
    self.collectionV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionV.backgroundColor = [UIColor whiteColor];
    self.collectionV.delegate = self;
    self.collectionV.dataSource = self;
    [channelsHoldView addSubview:self.collectionV];

    [self resetSubViewsFrame];
    
    [self.collectionV registerClass:[SortChannelCollecCell class] forCellWithReuseIdentifier:@"SortChannelCollecCell_id"];
}

//排序后重新计算channel标签宽度 重新设置cell宽度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(MTCollectionViewLayout *)collectionViewLayout sizeForItemAt:(NSIndexPath *)indexPath{
    [self countChannelsViewHeight];
    return [channelsRectArr[indexPath.row] CGRectValue].size;
}
 
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _addedChannels.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SortChannelCollecCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SortChannelCollecCell_id" forIndexPath:indexPath];
    cell.delegate = self;
    cell.showDeleteBtn = _isEditing;
    cell.deleteBtn.tag = indexPath.row;
    cell.textLabel.transform = CGAffineTransformMakeScale(1, 1);
    [cell.deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.textLabel.text = _addedChannels[indexPath.row];
    return cell;
}

- (void)deleteAction:(UIButton *)sender{
    NSString *d_title;
    NSArray *cells = [self.collectionV visibleCells];
    for (SortChannelCollecCell *cell in cells) {
        if(cell.deleteBtn.tag == sender.tag){
            d_title = cell.textLabel.text;
            //删除动画
            [_addedChannels removeObjectAtIndex:sender.tag];
            [UIView animateWithDuration:0.3 animations:^{
                
                cell.textLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
                cell.deleteBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
            } completion:^(BOOL finished) {
                
                [self countChannelsViewHeight];
                [self resetSubViewsFrame];
                [self.collectionV reloadData];
            }];
            break;
        }
    }
 
}
//MARK:CollecDragSortDelegate 拖拽手势触发
- (void)dargSortCellGestureAction:(UIGestureRecognizer *)gestureRecognizer{
    //记录上一次手势的位置
    static CGPoint startPoint;
    //触发长按手势的cell
    SortChannelCollecCell * cell = (SortChannelCollecCell *)gestureRecognizer.view;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        //开始长按
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            
            [manageBtn setSelected:YES];
            _isEditing = YES;
            
            self.collectionV.scrollEnabled = NO;
        }
        
        if (!_isEditing) {
            return;
        }
        
        NSArray *cells = [self.collectionV visibleCells];
        for (SortChannelCollecCell *cell in cells) {
            //长按编辑时 动画显示会有细小UI问题
//            cell.showDeleteBtn = YES;
            cell.deleteBtn.transform = CGAffineTransformMakeScale(1, 1);
            cell.deleteBtn.hidden = NO;
        }
        
        //获取cell的截图
        _snapshotView  = [cell snapshotViewAfterScreenUpdates:YES];
        _snapshotView.center = cell.center;
        [_collectionV addSubview:_snapshotView];
        _indexPath = [_collectionV indexPathForCell:cell];
        _originalCell = cell;
        _originalCell.hidden = YES;
        startPoint = [gestureRecognizer locationInView:_collectionV];
        
        //移动
    }else if (gestureRecognizer.state == UIGestureRecognizerStateChanged){
        
        CGFloat tranX = [gestureRecognizer locationOfTouch:0 inView:_collectionV].x - startPoint.x;
        CGFloat tranY = [gestureRecognizer locationOfTouch:0 inView:_collectionV].y - startPoint.y;
        
        //设置截图视图位置
        _snapshotView.center = CGPointApplyAffineTransform(_snapshotView.center, CGAffineTransformMakeTranslation(tranX, tranY));
        startPoint = [gestureRecognizer locationOfTouch:0 inView:_collectionV];
        //计算截图视图和哪个cell相交
        for (UICollectionViewCell *cell in [_collectionV visibleCells]) {
            //跳过隐藏的cell
            if ([_collectionV indexPathForCell:cell] == _indexPath) {
                continue;
            }
            //计算中心距
            CGFloat space = sqrtf(pow(_snapshotView.center.x - cell.center.x, 2) + powf(_snapshotView.center.y - cell.center.y, 2));
            
            //如果相交一半且两个视图Y的绝对值小于高度的一半就移动
            if (space <= _snapshotView.bounds.size.width * 0.5 && (fabs(_snapshotView.center.y - cell.center.y) <= _snapshotView.bounds.size.height * 0.5)) {
                _nextIndexPath = [_collectionV indexPathForCell:cell];
                if (_nextIndexPath.item > _indexPath.item) {
                    for (NSUInteger i = _indexPath.item; i < _nextIndexPath.item ; i ++) {
                        [_addedChannels exchangeObjectAtIndex:i withObjectAtIndex:i+1];
 
                    }
                }else{
                    for (NSUInteger i = _indexPath.item; i > _nextIndexPath.item ; i --) {
                        [_addedChannels exchangeObjectAtIndex:i withObjectAtIndex:i-1];
                    }
                }
                //移动
                [_collectionV moveItemAtIndexPath:_indexPath toIndexPath:_nextIndexPath];
                //设置移动后的起始indexPath
                _indexPath = _nextIndexPath;
                break;
            }
        }
        //停止
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        [_snapshotView removeFromSuperview];
        _originalCell.hidden = NO;
    }
    
    //重新根据修改的 channel title 数组计算对应cell的尺寸
    [self countChannelsViewHeight];
    [self resetSubViewsFrame];
}

//MARK:计算所有标签的rect保存并计算出标签父视图的高度
- (CGFloat)countChannelsViewHeight{
    
    channelsRectArr = [[NSMutableArray alloc] init];
    CGFloat itemsViewW = 0;     //每一行items宽度和及间隙和 判断是否要换行
    CGFloat xPoint = 0;
    CGFloat yPoint = 0;
    NSInteger lines = 1;
    for (int i=0; i<_addedChannels.count; i++) {
        NSString *str = _addedChannels[i];
        CGFloat btnW = [self widthForString:str andHeight:channelItem_H];
        itemsViewW += btnW+3;                  //删除图标距离后一个item为3
        if (itemsViewW+side_gap*2-3+15 > APPW){  //每行最后一个item边距小于20时换行
            lines += 1;
            itemsViewW = btnW;
            xPoint = 0;
            yPoint = (lines-1)*(channelItem_H+vertical_gap);
        }
        if (xPoint == 0){
            xPoint = side_gap;
        }else{
            CGRect lastR = [channelsRectArr[i-1] CGRectValue];
            xPoint = CGRectGetMaxX(lastR)+3;
        }
        CGRect itemRect = CGRectMake(xPoint, yPoint, btnW, channelItem_H);
        [channelsRectArr addObject:[NSValue valueWithCGRect:itemRect]];
    }
    
    //item高度+底部间距
    return CGRectGetMaxY([channelsRectArr.lastObject CGRectValue])+14;
}
- (float)widthForString:(NSString *)value andHeight:(float)height
{
    NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:12.f ]};
    CGRect strRect =   [value boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
    //文字两边各间隙15
    return strRect.size.width+30;
}
- (void)resetSubViewsFrame{
    
    CGFloat cv_height = 10 + CGRectGetMaxY([channelsRectArr.lastObject CGRectValue]) + 14;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.collectionV setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, cv_height)];
    }];
    
    [self resetFrameWithAnimation:cv_height];
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(addedChannelsView.frame));
}
- (void)resetFrameWithAnimation:(CGFloat)cv_height{
    [UIView animateWithDuration:0.3 animations:^{
//        CGRectGetMaxY(已添加频道)+10 = 48
        [addedChannelsView setFrame:CGRectMake(0, 0, APPW, 48+cv_height)];
        [channelsHoldView setFrame:CGRectMake(0, 48, APPW, cv_height)];
    }];
}

//MARK:==== Action
- (void)manageAction:(UIButton *)sender{
    
    [sender setSelected:!sender.isSelected];
    _isEditing = sender.isSelected;
    [self.collectionV reloadData];
    
}

- (void)backAction{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


#define itemHeight 35.5
@interface SortChannelCollecCell()<UIGestureRecognizerDelegate>

@end
@implementation SortChannelCollecCell
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]){
        self.contentView.backgroundColor = [UIColor clearColor];
 
        [self initUI];
    }
         return self;
}
- (void)initUI{
    
    //给每个cell添加一个长按手势
    UILongPressGestureRecognizer * longPress =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer * pan =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    _textLabel.layer.masksToBounds = YES;
    _textLabel.layer.cornerRadius = 1;
    _textLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_textLabel];
    /*
     如果使用CGRectMake来布局,是需要在preferredLayoutAttributesFittingAttributes方法中去修改textlabel的frame
     如果使用约束来布局,则无需在preferredLayoutAttributesFittingAttributes方法中去修改cell上的子控件l的frame
    */
    
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(self.contentView).with.offset(7.5);
        make.left.equalTo(self.contentView).with.offset(0);
        make.height.equalTo(@(itemHeight-7.5));
        make.right.equalTo(self.contentView).with.offset(-7.5);
    }];
    
    _deleteBtn = [[UIButton alloc] init];
    _deleteBtn.layer.masksToBounds = YES;
    _deleteBtn.layer.cornerRadius = 7.5;
    _deleteBtn.hidden = YES;
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"grayDelete"] forState:UIControlStateNormal];
    [self.contentView addSubview:_deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.contentView).with.offset(0);
        make.right.equalTo(self.contentView.mas_right).with.offset(0);
        make.width.height.equalTo(@(15));
    }];
}


- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes{
    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:12.f ]};
    CGRect rect =   [_textLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, itemHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
 
    rect.size.width += 30;
    rect.size.height = 35.5;
    attributes.frame = rect;
    return attributes;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && _deleteBtn.hidden) {
        return NO;
    }
    return YES;
}
- (void)gestureAction:(UIGestureRecognizer *)gestureRecognizer{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dargSortCellGestureAction:)]) {
        [self.delegate dargSortCellGestureAction:gestureRecognizer];
    }
}
//MARK: Animation
- (void)setShowDeleteBtn:(BOOL)showDeleteBtn{

    //记录上一次删除键的显示状态
    BOOL beforeShowDelete = !_deleteBtn.hidden;

    _deleteBtn.transform = CGAffineTransformMakeScale(1, 1);
    if (showDeleteBtn){
        _deleteBtn.hidden = !showDeleteBtn;
        if (!beforeShowDelete){

            _deleteBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
            [UIView animateWithDuration:0.3 animations:^{
                _deleteBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    _deleteBtn.transform = CGAffineTransformMakeScale(1, 1);
                }];
            }];
        }
    }else{

        [UIView animateWithDuration:0.3 animations:^{
            _deleteBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
        } completion:^(BOOL finished) {
            _deleteBtn.hidden = !showDeleteBtn;
        }];
    }
}
@end



