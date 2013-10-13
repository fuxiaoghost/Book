//
//  PhotoLayer.m
//  Book
//
//  Created by Dawn on 13-10-13.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import "PaperLayer.h"

@interface PaperLayer()
@property (nonatomic,assign) PaperLayerOrientation paperOrientation;
@end
@implementation PaperLayer
@synthesize paperOrientation;
@synthesize image;
@synthesize markView;

- (void)dealloc {
	self.image			= nil;
	CGImageRelease(imageRef);
	
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame paperType:(PaperLayerOrientation)orientation{
    if (self = [super initWithFrame:frame]) {
        self.paperOrientation = orientation;
        self.layer.shouldRasterize = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        markView = [[UIView alloc] initWithFrame:self.bounds];
        markView.backgroundColor = [UIColor blackColor];
        markView.alpha = 0;
        markView.layer.cornerRadius = 25.0f;
        [self addSubview:markView];
        [markView release];
        if (orientation == PaperLayerLeft) {
            markView.frame = CGRectMake(0, 0, frame.size.width + 30, frame.size.height);
        }else if(orientation == PaperLayerRight){
            markView.frame = CGRectMake(-30, 0, frame.size.width + 30, frame.size.height);
        }
    }
    return self;
}

- (void) setFrame:(CGRect)frame{
    if (frame.size.width == self.frame.size.width) {
        [super setFrame:frame];
        return;
    }
    [super setFrame:frame];
    if (self.paperOrientation == PaperLayerLeft) {
        markView.frame = CGRectMake(0, 0, frame.size.width + 30, frame.size.height);
    }else if(self.paperOrientation == PaperLayerRight){
        markView.frame = CGRectMake(-30, 0, frame.size.width + 30, frame.size.height);
    }
    
    [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat height = self.bounds.size.height;
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSaveGState(context);

	
	CGRect rrect = CGRectMake(0, 0, rect.size.width, rect.size.height);
	CGFloat radius = 25.0f;
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
    if (self.paperOrientation == PaperLayerLeft) {
        // Start at 1
        CGContextMoveToPoint(context, minx, midy);
        // Add an arc through 2 to 3
        CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
        // Add an arc through 4 to 5
        CGContextAddLineToPoint(context, maxx, miny);
        // Add an arc through 6 to 7
        CGContextAddLineToPoint(context, maxx, maxy);
        // Add an arc through 8 to 9
        CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
        // Close the path
        CGContextClosePath(context);
    }else{
        // Start at 1
        CGContextMoveToPoint(context, minx, midy);
        // Add an arc through 2 to 3
        CGContextAddLineToPoint(context, minx, miny);
        // Add an arc through 4 to 5
        CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
        // Add an arc through 6 to 7
        CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
        // Add an arc through 8 to 9
        CGContextAddLineToPoint(context, minx, maxy);
        // Close the path
        CGContextClosePath(context);
    }
	
	
	if (imageRef) {
		CGContextClip(context);
		CGContextDrawImage(context, self.bounds, imageRef);
	}else {
		// Fill & stroke the path
		CGContextDrawPath(context, kCGPathFillStroke);
	}
}

- (void)setImage:(UIImage *)img {
    CGImageRelease(imageRef);
    if (self.paperOrientation == PaperLayerLeft) {
        imageRef = CGImageCreateWithImageInRect(img.CGImage, CGRectMake(0, 0, CGImageGetWidth(img.CGImage)/2.0f, CGImageGetHeight(img.CGImage)));
        
    }else if(self.paperOrientation == PaperLayerRight){
        imageRef = CGImageCreateWithImageInRect(img.CGImage, CGRectMake(CGImageGetWidth(img.CGImage)/2.0f, 0, CGImageGetWidth(img.CGImage)/2.0f, CGImageGetHeight(img.CGImage)));
    }
	[self setNeedsDisplay];
}

@end
