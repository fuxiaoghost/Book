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

@interface PaperCell : UIView
- (id)initWithFrame:(CGRect)frame orientation:(PaperCellOrientation)orientation;
@end
