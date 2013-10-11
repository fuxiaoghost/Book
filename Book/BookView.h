//
//  BookView.h
//  Book
//
//  Created by Dawn on 13-10-6.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookView : UIView{
@private
    BOOL _isMoving;
    CGPoint startTouch;
}
@property (nonatomic,retain) UIImage *coverImage;
- (id)initWithFrame:(CGRect)frame photoUrls:(NSArray *)urls;
@end
