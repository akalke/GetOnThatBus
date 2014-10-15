//
//  StopDetailViewController.m
//  GetOnThatBus
//
//  Created by Amaeya Kalke on 10/15/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "StopDetailViewController.h"

@interface StopDetailViewController ()
@end

@implementation StopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.title = self.stopName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
