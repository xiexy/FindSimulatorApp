//
//  AppDelegate.m
//  FindSimulatorApp
//
//  Created by xiexy on 2017/12/29.
//  Copyright © 2017年 xiexy. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) NSPopover *popover;   // 弹窗
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//    NSLog(@"%s",__func__);
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSImage *image = [NSImage imageNamed:@"AppIcon"];
    [self.statusItem.button setImage: image];
    _popover = [[NSPopover alloc]init];
    [_popover setAnimates:NO];
    _popover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    ViewController *vc = [[ViewController alloc] init];
    _popover.contentViewController = vc;
    self.statusItem.button.action = @selector(showMyPopover:);
    __weak typeof (self) weakSelf = self;
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskLeftMouseDown handler:^(NSEvent * event) {
        if (weakSelf.popover.isShown) {
            [weakSelf.popover close];
        }
    }];
}

- (void)showMyPopover:(NSStatusBarButton *)button{
    [_popover showRelativeToRect:button.bounds ofView:button preferredEdge:NSRectEdgeMaxY];
}


@end
