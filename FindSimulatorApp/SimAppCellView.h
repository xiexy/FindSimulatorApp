//
//  SimAppCellView.h
//  FindSimulatorApp
//
//  Created by xiexy on 2017/12/29.
//  Copyright © 2017年 xiexy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SimAppModel.h"

@interface SimAppCellView : NSTableCellView
@property (strong, nonatomic) SimAppModel *appModel;
@end
