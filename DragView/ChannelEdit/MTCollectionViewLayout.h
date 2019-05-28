//
//  MTCollectionViewLayout.h
//  SportsAppTest
//
//  Created by JiaJunTan on 2019/1/7.
//  Copyright © 2019年 JiaJunTan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MTCollectionViewLayout;

@protocol IMTCollectionViewLayoutDelegate

- (CGSize)collectionView:(UICollectionView *_Nullable)collectionView layout:(MTCollectionViewLayout *_Nullable)collectionViewLayout sizeForItemAt:(NSIndexPath *_Nullable)indexPath;

@optional
- (CGSize)collectionView:(UICollectionView * _Nullable)coMTCollectionViewLayoutllectionView layout:(MTCollectionViewLayout * _Nonnull)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView * _Nullable)collectionView layout:(MTCollectionViewLayout * _Nonnull)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;
@end

@interface MTCollectionViewLayout : UICollectionViewLayout{
    
    NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *cellAttributes;
    NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *headerAttributes;
    NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *footerAttributes;
    CGFloat currentY;
}
@property(nonatomic,weak)id<IMTCollectionViewLayoutDelegate> delegate;
@property(nonatomic,assign)CGFloat MaximumSpacing;
@property(nonatomic,assign)CGFloat minimumLineSpacingForSection;
@property(nonatomic,assign)UIEdgeInsets sectionEdgeInsets;
@end
