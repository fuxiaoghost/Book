/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "PhotoProgressView.h"

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    self.image = placeholder;

    [manager downloadWithURL:url delegate:self options:options];
}

- (void)setImageWithURL:(NSURL *)url options:(SDWebImageOptions)options progress:(BOOL)progress{
    if(progress){
		PhotoProgressView *progressView = (PhotoProgressView *)[self viewWithTag:2013];
		if (!progressView) {
			
			CGSize progressSize = CGSizeMake(40, 40);
            
			if (progressSize.width>progressSize.height) {
				progressSize = CGSizeMake(round(progressSize.height), round(progressSize.height));
			}else {
				progressSize = CGSizeMake(round(progressSize.width), round(progressSize.width));
			}
            
			progressView = [[PhotoProgressView alloc] initWithFrame:CGRectMake((self.frame.size.width-progressSize.width)/2, (self.frame.size.height-progressSize.height)/2, progressSize.width,progressSize.height)];
			[self addSubview:progressView];
			[progressView release];
            
            if (self.transform.a <= 0) {
                progressView.center = CGPointMake(self.frame.size.height/2,self.frame.size.width/2);
            }else{
                progressView.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
            }
		}
		
		[progressView setProgress:0.01];
		progressView.tag = 2013;
		progressView.hidden = NO;
        [self setImageWithURL:url placeholderImage:nil options:options];
	}else{
        [self setImageWithURL:url placeholderImage:[UIImage noCacheImageWithName:@"noImage_replace.png"] options:options];
    }
}


#if NS_BLOCKS_AVAILABLE
- (void)setImageWithURL:(NSURL *)url success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure;
{
    [self setImageWithURL:url placeholderImage:nil success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure;
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure;
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    self.image = placeholder;
    
    [manager downloadWithURL:url delegate:self options:options success:success failure:failure];
}
#endif

- (void)cancelCurrentImageLoad
{
    @synchronized(self)
    {
        [[SDWebImageManager sharedManager] cancelForDelegate:self];
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didProgressWithPartialImage:(UIImage *)image forURL:(NSURL *)url
{
    self.image = image;
    [self setNeedsLayout];
}

- (void) webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error{
    PhotoProgressView *progressView = (PhotoProgressView *)[self viewWithTag:2013];
	if (progressView) {
		[progressView removeFromSuperview];
	}
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    
    UIProgressView *progressView = (UIProgressView *)[self viewWithTag:2013];
	if (progressView) {
		[progressView removeFromSuperview];
	}
    
    self.image = image;
    [self setNeedsLayout];
}

- (void) webImageManager:(SDWebImageManager *)imageManager didChangedProgress:(float)progress{
    PhotoProgressView *progressView = (PhotoProgressView *)[self viewWithTag:2013];
	progressView.hidden = NO;
	if (progressView) {
		[progressView setProgress:progress];
	}
}
@end
