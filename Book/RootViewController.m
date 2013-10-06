//
//  RootViewController.m
//  Book
//
//  Created by Dawn on 13-10-6.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import "RootViewController.h"
#import "BookView.h"

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
    BookView *bookView = [[BookView alloc] initWithFrame:CGRectMake(10, 20, 568 - 20, 280) photoUrls:[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photos" ofType:@"plist"]]];
    bookView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:bookView];
    [bookView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
