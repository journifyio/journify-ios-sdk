//
//  ViewController.m
//  ObjCExample
//
//  Created by Mohammed on 2/8/23.
//

#import "ViewController.h"
@import Journify;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [JFJournify screen:@"Page" category:nil properties:@{@"name": @"ViewController"}];
}


@end
