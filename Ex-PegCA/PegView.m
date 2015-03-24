//
//  PegView.m
//  Ex-PegCA
//
//  Created by Steven Senger on 10/15/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "PegView.h"

@implementation PegView{
    CATextLayer *textLayer;
}

- (void)drawRect:(CGRect)rect {
    
    [[UIColor blueColor] set];
    [[UIBezierPath bezierPathWithOvalInRect: rect] fill];
    textLayer = [[CATextLayer alloc] init];
    textLayer.string = [NSString stringWithFormat:@"%i", self.index];
    [textLayer setFontSize:22];
    if( self.index >= 10 )
        textLayer.frame = CGRectMake(2, 2, 30, 30);
    else
        textLayer.frame = CGRectMake(10, 3, 22, 29);
    [self.layer addSublayer:textLayer];
}

@end
