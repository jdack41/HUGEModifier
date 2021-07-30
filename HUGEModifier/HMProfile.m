//
//  HMProfile.m
//  HUGEModifier
//
//  Created by hiroki on 2020/09/29.
//  Copyright © 2020 hiroki. All rights reserved.
//

#import "HMProfile.h"
#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioToolbox.h>
#import "HMManager.h"

@implementation HMProfile

- (instancetype)init
{
    if (self = [super init]) {
        virtualHID = [HMVirtualHID shared];
        isVerticalScroll = false;
        isHorizontalScroll = false;
    }
    return self;
}

- (void)clicked:(uint8_t)button isDown:(BOOL)down manager:(HMManager*)manager {
    
    if (button == 6) { // Fn2
        [virtualHID button:4 down:down];
    } else if (button == 7) { // Fn3
        if (!down) return;
        [virtualHID control:YES];
        [virtualHID key:kHIDUsage_KeyboardUpArrow down:YES];
        [virtualHID control:NO];
        [virtualHID key:kHIDUsage_KeyboardUpArrow down:NO];
    } else if (button == 0) { // L
        [virtualHID button:1 down:down];
    } else if (button == 5) { // Fn1
        [virtualHID button:5 down:down];
    } else if (button == 4) { // <
        if(!isVerticalScroll) {
            if (!down) return;
            isVerticalScroll = true;
        } else {
            if (!down) return;
            isVerticalScroll = false;
            isHorizontalScroll = false;
        }
    } else if (button == 3) { // >
        if(!isHorizontalScroll) {
            if (!down) return;
            isHorizontalScroll = true;
        } else {
            if (!down) return;
            isVerticalScroll = false;
            isHorizontalScroll = false;
        }
    } else if (button == 2) { // WheelClick Launchpad
        if (!down) return;
        [self openApplication:@"Launchpad"];
    } else if (button == 1) { // R
        [virtualHID button:2 down:down];
    }
    
//    if (down) printf("Button %d down\n", button);
//    else printf("Button %d up\n", button);
}

- (void)movedX:(int16_t)x Y:(int16_t)y manager:(HMManager*)manager {
    if ([manager isMouseDown:4]) {
        [self rotateWheel:CGPointMake(0, y)];
        isVerticalScroll = false;
        isHorizontalScroll = false;
    } else if ([manager isMouseDown:3]) {
        [self rotateWheel:CGPointMake(x, 0)];
        isVerticalScroll = false;
        isHorizontalScroll = false;
    } else if (isVerticalScroll) {
        [self rotateWheel:CGPointMake(0, y)];
    } else if (isHorizontalScroll) {
        [self rotateWheel:CGPointMake(x, 0)];
    } else {
        [virtualHID moveX:x Y:y];
    }
//    printf("move (%d, %d)\n", x, y);
}

- (void)wheelVertical:(int16_t)vertical manager:(HMManager*)manager {
    [virtualHID wheelVertical:vertical Horizontal:0];
}

- (void)wheelHorizontal:(int16_t)horizontal manager:(HMManager*)manager {
    uint8_t code = kHIDUsage_KeyboardLeftArrow;
    if (horizontal < 0) code = kHIDUsage_KeyboardRightArrow;
    [virtualHID control:YES];
    [virtualHID key:code down:YES];
    [virtualHID control:NO];
    [virtualHID key:code down:NO];
}

- (void)rotateWheel:(CGPoint)offset {
    CGEventRef scroll = CGEventCreateScrollWheelEvent2(nil, kCGScrollEventUnitPixel, 2, offset.y * 1.5, offset.x * 1, 0);
//    CGEventRef scroll = CGEventCreateScrollWheelEvent(nil, kCGScrollEventUnitPixel, 2, offset.y * 1.5, offset.x * 1.5);
    CGEventPost(kCGHIDEventTap, scroll);
    CFRelease(scroll);
}

-(void)openApplication:(NSString*)application {
    NSString *command = [NSString stringWithFormat:@"open -a \"%@\"", application];
    system([command UTF8String]);
}


@end
