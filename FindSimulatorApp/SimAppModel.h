//
//  SimAppModel.h
//  FindSimulatorApp
//
//  Created by xiexy on 2017/12/29.
//  Copyright © 2017年 xiexy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimAppModel : NSObject
@property (copy, nonatomic) NSString *simulatorDeviceName;
@property (copy, nonatomic) NSString *simAppName;
@property (copy, nonatomic) NSString *simIdentifier;
@property (copy, nonatomic) NSString *simAppPath;
@property (copy, nonatomic) NSString *simLibPath;
@property (strong, nonatomic) NSImage *simAppIcon;
@end
