//
//  PaperView.h
//  Book
//
//  Created by Dawn on 13-10-8.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaperView : UIView{
@private
    BOOL _isMoving;
    CGPoint startTouch;
    NSInteger startPageIndex;
    float moveSensitivity;
    float zDistance;
}
@property (nonatomic,assign) NSInteger pageIndex;
- (id)initWithFrame:(CGRect)frame photoUrls:(NSArray *)urls;
@end
