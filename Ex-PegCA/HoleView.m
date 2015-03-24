//
//  HoleView.m
//  Ex-PegCA
//
//  Created by Steven Senger on 10/15/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "HoleView.h"

@implementation HoleView

- (void)drawRect:(CGRect)rect {
  [[UIColor lightGrayColor] set];
  [[UIBezierPath bezierPathWithOvalInRect: rect] fill];
  
  if (self.active) {
    [[UIColor yellowColor] set];
    [[UIBezierPath bezierPathWithOvalInRect: rect] stroke];
  }
}

@end
