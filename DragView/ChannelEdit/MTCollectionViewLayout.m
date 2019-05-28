//
//  MTCollectionViewLayout.m
//  SportsAppTest
//
//  Created by JiaJunTan on 2019/1/7.
//  Copyright © 2019年 JiaJunTan. All rights reserved.
//

#import "MTCollectionViewLayout.h"

@implementation MTCollectionViewLayout

- (void)prepareLayout{
    [super prepareLayout];
    cellAttributes = [[NSMutableDictionary alloc] init];
    headerAttributes = [[NSMutableDictionary alloc] init];
    footerAttributes = [[NSMutableDictionary alloc] init];
    currentY = 0;
    
    NSInteger sectionNum = self.collectionView.numberOfSections? self.collectionView.numberOfSections:0;
    
    for(NSInteger i=0;i<sectionNum;i++){
        NSIndexPath *supplementaryViewIndex = [NSIndexPath indexPathForRow:0 inSection:i];
        //计算设置每个header的布局对象
        UICollectionViewLayoutAttributes *headerAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:supplementaryViewIndex];
//        CGSize headerSize = [_delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:supplementaryViewIndex.section];
        CGSize headerSize = CGSizeMake(0, 0);
        headerAttribute.frame = CGRectMake(0, currentY, headerSize.width, headerSize.height);
        headerAttributes[supplementaryViewIndex] = headerAttribute;
        currentY = CGRectGetMaxY(headerAttribute.frame)+_sectionEdgeInsets.top;
        
        //计算设置每个cell的布局对象
        //该section一共有多少row
        NSInteger rowNum = [self.collectionView numberOfItemsInSection:i];
        CGFloat currentX = _sectionEdgeInsets.left;
        for(NSInteger j=0;j<rowNum;j++){
            NSIndexPath *cellIndex = [NSIndexPath indexPathForRow:j inSection:i];
            UICollectionViewLayoutAttributes *cellAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
            CGSize cellSize = [_delegate collectionView:self.collectionView layout:self sizeForItemAt:cellIndex];
            if (currentX+cellSize.width+_sectionEdgeInsets.right > self.collectionView.frame.size.width){
                //超过collectview换行,并且collectionview的高度增加
                currentX = _sectionEdgeInsets.left;
                currentY = currentY + cellSize.height + _minimumLineSpacingForSection;
            }
            cellAttribute.frame = CGRectMake(currentX, currentY, cellSize.width, cellSize.height);
            currentX = currentX + cellSize.width + _MaximumSpacing;
            cellAttributes[cellIndex] = cellAttribute;
            if (j == rowNum-1){
                currentY = currentY + cellSize.height + _sectionEdgeInsets.bottom;
            }
        }
        
        //计算每个footer的布局对象
        UICollectionViewLayoutAttributes *footerAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:supplementaryViewIndex];
//        CGSize footerSize = [_delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:i];
        CGSize footerSize = CGSizeMake(0, 0);
        footerAttribute.frame = CGRectMake(0, currentY, footerSize.width, footerSize.height);
        footerAttributes[supplementaryViewIndex] = footerAttribute;
        currentY = currentY + footerSize.height;
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> * _Nullable)layoutAttributesForElementsInRect:(CGRect)rect{
    [super layoutAttributesForElementsInRect:rect];
    NSMutableArray<UICollectionViewLayoutAttributes *> *attributes = [[NSMutableArray alloc]init];
     //  添加当前屏幕可见的cell的布局
    
    for(UICollectionViewLayoutAttributes *element in cellAttributes.allValues){
        if (CGRectContainsRect(rect, element.frame)){
            [attributes addObject:element];
        }
    }
    //  添加当前屏幕可见的头视图的布局
    for(UICollectionViewLayoutAttributes *element in headerAttributes.allValues){
        if (CGRectContainsRect(rect, element.frame)){
            [attributes addObject:element];
        }
    }
    //  添加当前屏幕可见的尾部的布局
    for(UICollectionViewLayoutAttributes *element in footerAttributes.allValues){
        if (CGRectContainsRect(rect, element.frame)){
            [attributes addObject:element];
        }
    }
    return attributes;
}
- (UICollectionViewLayoutAttributes * _Nullable)layoutAttributesForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath{
    [super layoutAttributesForItemAtIndexPath:indexPath];
    return cellAttributes[indexPath];
}
- (UICollectionViewLayoutAttributes * _Nullable)layoutAttributesForSupplementaryViewOfKind:(NSString * _Nonnull)elementKind atIndexPath:(NSIndexPath * _Nonnull)indexPath{
    [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
    UICollectionViewLayoutAttributes *attr;
    if (elementKind == UICollectionElementKindSectionHeader){
        attr = headerAttributes[indexPath];
    }else{
        attr = footerAttributes[indexPath];
    }
    return attr;
}
- (CGSize)collectionViewContentSize{
    [super collectionViewContentSize];
    CGFloat width = self.collectionView.frame.size.width;
    return CGSizeMake(width, currentY);
}

@end
