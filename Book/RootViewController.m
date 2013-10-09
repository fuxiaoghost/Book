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
    PaperView *paperView = [[PaperView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_HEIGHT-20, SCREEN_WIDTH-40) photoUrls:[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photos" ofType:@"plist"]]];
    paperView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:paperView];
    [paperView release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
