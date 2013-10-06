//
//  UIImage+Utils.m
//  Artist
//
//  Created by Dawn on 13-9-4.
//  Copyright (c) 2013年 ArtAppSolution. All rights reserved.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)
/* 从文件中获取图片 */
+(UIImage *)noCacheImageWithName:(NSString *)imageName{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

/* 拉伸图片 */
+(UIImage *)strenchImageWithImageName:(NSString *)imageName{
    UIImage *tmpImage = [UIImage noCacheImageWithName:imageName];
    UIImage *strenchImage = [tmpImage stretchableImageWithLeftCapWidth:tmpImage.size.width/2 topCapHeight:tmpImage.size.height/2];
    return strenchImage;
}
/* 根据颜色手动绘制图片 */
+(UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    //    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    UIGraphicsBeginImageContext(size);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *renderImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return renderImage;
}

@end