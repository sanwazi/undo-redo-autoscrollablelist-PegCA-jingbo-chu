//
//  PascalLayout.m
//  Ex-PegCA
//
//  Created by Steven Senger on 10/16/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "PascalLayout.h"

@interface PascalLayout ()
@property (assign) CGPoint base;
@property (assign) CGFloat scale;
@end

int Sum(int v) {
  int ret = v--;
  while (v > 0) ret = ret + v--;
  return ret;
}

@implementation PascalLayout // first is row, second is position in row
int indices[15][2] = {              {0,0},                   //                0
                                {1,0}, {1,1},                //              1   2
                             {2,0}, {2,1}, {2,2},            //            3   4   5
                         {3,0}, {3,1}, {3,2}, {3,3},         //          6   7   8   9
                      {4,0}, {4,1}, {4,2}, {4,3}, {4,4}};    //        10  11  12  13  14

- (id) initWithBase: (CGPoint) base andScale: (CGFloat) scale {
  self = [super init];
  if (self) {
    _base = base;
    _scale = scale;
  }
  return self;
}

- (BOOL) index: (int) indexA canJumpTo: (int) indexB {
  if (indexA < 0 || indexA > 14 || indexB < 0 || indexB > 14) return NO;
  
  return    ( (indices[indexA][0] == indices[indexB][0] + 2)
              && (indices[indexA][1] == indices[indexB][1] || indices[indexA][1] == indices[indexB][1] + 2))
         || ( (indices[indexA][0] == indices[indexB][0])
              && (indices[indexA][1] == indices[indexB][1] + 2 || indices[indexB][1] == indices[indexA][1] + 2))
         || ( (indices[indexB][0] == indices[indexA][0] + 2)
              && (indices[indexB][1] == indices[indexA][1] || indices[indexB][1] == indices[indexA][1] + 2));
}

- (int) indexBetween: (int) indexA and: (int) indexB {
  if (indexA < 0 || indexA > 14 || indexB < 0 || indexB > 14) return -1;
  
  int midRow = (indices[indexA][0] + indices[indexB][0]) / 2.0;
  int midPos = (indices[indexA][1] + indices[indexB][1]) / 2.0;
  return Sum(midRow) + midPos;
}

- (CGPoint) coordForIndex: (int) index {
  if (index < 0 || index > 14) return CGPointMake(-1,-1);
  CGFloat x = self.base.x - indices[index][0] * 0.5 * self.scale + indices[index][1] * self.scale;
  CGFloat y = indices[index][0] * 0.86225 * self.scale + self.base.y;
  return CGPointMake(x,y);
}

@end
