//
//  RootViewController.m
//  Book
//
//  Created by Dawn on 13-10-6.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#define SCREEN_WIDTH			([[UIScreen mainScreen] bounds].size.width)         // Screen width
#define SCREEN_HEIGHT			([[UIScreen mainScreen] bounds].size.height)        // Screen height

#import "RootViewController.h"
#import "PaperView.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
	// Do any additional setup after loading the view.
    
    NSMutableArray *imageArray = [NSMutableArray array];
    for (int i = 20; i < 40; i++) {
        [imageArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i]]];
    }
    
    paperView = [[PaperView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT) images:imageArray];
    paperView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:paperView];
    [paperView release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UIViewControllerRotation
- (BOOL)shouldAutorotate{
    return YES;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        paperView.frame = CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT);
    }else{
        paperView.frame = CGRectMake(0, 0,SCREEN_HEIGHT,SCREEN_WIDTH);
    }
    
}


- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}


@end
