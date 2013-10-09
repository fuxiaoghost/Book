//
//  PaperCell.h
//  Book
//
//  Created by Dawn on 13-10-8.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef enum {
    PaperCellLeft,
    PaperCellRight
}PaperCellOrientation;

@interface PaperCell : UIView{
@private
    UIImageView *photoView;
    UILabel *tipsLbl;
    UIView *markView;
}
@property (nonatomic,readonly) UIImageView *photoView;
@property (nonatomic,readonly) UILabel *tipsLbl;
@property (nonatomic,readonly) UIView *markView;
- (id)initWithFrame:(CGRect)frame orientation:(PaperCellOrientation)orientation;
@end
