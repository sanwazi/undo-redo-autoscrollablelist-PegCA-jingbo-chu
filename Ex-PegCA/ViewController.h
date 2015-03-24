//
//  ViewController.h
//  Ex-PegCA
//
//  Created by Steven Senger on 10/15/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property( retain, nonatomic ) NSUndoManager *undoManager;
@end

