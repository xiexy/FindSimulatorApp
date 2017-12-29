//
//  SimAppCellView.m
//  FindSimulatorApp
//
//  Created by xiexy on 2017/12/29.
//  Copyright © 2017年 xiexy. All rights reserved.
//

#import "SimAppCellView.h"
@interface SimAppCellView()
@property (weak) IBOutlet NSImageView *appIconView;
@property (weak) IBOutlet NSTextField *appNameLabel;
@property (weak) IBOutlet NSTextField *appIdentifierLabel;

@end
@implementation SimAppCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
   
}
- (void)setAppModel:(SimAppModel *)appModel
{
    _appModel = appModel;
    self.appIconView.image = appModel.simAppIcon ? appModel.simAppIcon : [NSImage imageNamed:@"defaut"];
    NSString *strName = appModel.simAppName;
    if(appModel.simulatorDeviceName.length > 0){
       strName = [strName stringByAppendingFormat:@" (%@)",appModel.simulatorDeviceName];
    }
    self.appNameLabel.stringValue = strName;
    self.appIdentifierLabel.stringValue = appModel.simIdentifier;
}
@end
