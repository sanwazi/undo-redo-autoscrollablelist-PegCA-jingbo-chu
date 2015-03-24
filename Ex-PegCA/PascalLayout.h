//
//  PascalLayout.h
//  Ex-PegCA
//
//  Created by Steven Senger on 10/16/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PascalLayout : NSObject

- (id) initWithBase: (CGPoint) base andScale: (CGFloat) scale;
- (BOOL) index: (int) indexA canJumpTo: (int) indexB;
- (int) indexBetween: (int) indexA and: (int) indexB;
- (CGPoint) coordForIndex: (int) index;

@end
