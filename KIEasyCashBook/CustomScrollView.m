//
//  CustomScrollView.m
//  KIEasyCashBook
//
//  Created by 今井啓輔 on 2015/02/12.
//  Copyright (c) 2015年 今井啓輔. All rights reserved.
//

#import "CustomScrollView.h"

@implementation CustomScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging) {
        [self.nextResponder touchesEnded: touches withEvent:event];
    }
    [super touchesEnded: touches withEvent: event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging) {
        [self.nextResponder touchesBegan:touches withEvent:event];
    }
    [super touchesBegan:touches withEvent:event];
}

@end
