//
//  UIImage+Utils.h
//  Artist
//
//  Created by Dawn on 13-9-4.
//  Copyright (c) 2013年 ArtAppSolution. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)
/* 从文件中获取图片 */
+(UIImage *)noCacheImageWithName:(NSString *)imageName;
/* 拉伸图片 */
+(UIImage *)strenchImageWithImageName:(NSString *)imageName;
+(UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
@end
