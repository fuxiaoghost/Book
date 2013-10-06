//
//  PhotoProgressView.h
//  Elong_iPad
//	
//	图片下载进度指示器
//
//  Created by Wang Shuguang on 12-5-15.
//  Copyright 2012 elong. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoProgressView : UIView {
	float progress;
	UILabel *progressTips;
}
@property (nonatomic) float progress;
	
@end
