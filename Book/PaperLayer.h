//
//  PhotoLayer.h
//  Book
//
//  Created by Dawn on 13-10-13.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

typedef enum {
    PaperLayerLeft,
    PaperLayerRight
}PaperLayerOrientation;



#import <QuartzCore/QuartzCore.h>

@interface PaperLayer : UIView{
@private
    CGImageRef imageRef;
    UIView *markView;
}
@property (nonatomic,readonly) UIView *markView;
- (BOOL) haveImage;
- (void)setImage:(UIImage *)img;
- (id) initWithFrame:(CGRect)frame paperType:(PaperLayerOrientation)orientation;
@end
