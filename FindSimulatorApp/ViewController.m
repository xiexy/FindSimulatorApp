//
//  ViewController.m
//  FindSimulatorApp
//
//  Created by xiexy on 2017/12/29.
//  Copyright © 2017年 xiexy. All rights reserved.
//

#import "ViewController.h"
#import "SimAppModel.h"
#import "SimAppCellView.h"

@interface ViewController()<NSTableViewDataSource,NSTableViewDelegate>
@property (strong, nonatomic) NSMutableArray<SimAppModel *>  *dataSource;
@property (weak) IBOutlet NSTableView *tableView;
@end

@implementation ViewController
static NSString * const reUserId = @"SimAppCellView";
- (void)viewDidLoad {
    [super viewDidLoad];
    NSNib *nib = [[NSNib alloc] initWithNibNamed:@"SimAppCellView" bundle:nil];
    [self.tableView registerNib:nib forIdentifier:reUserId];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.action = @selector(openInFinder);
    NSTableHeaderView *tableHeaderView = [[NSTableHeaderView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
    [self.tableView setHeaderView:tableHeaderView];
}


- (void)openInFinder
{
//    NSLog(@"%@ - >%@",@(self.tableView.clickedRow),@(self.tableView.clickedColumn));
    NSInteger row = self.tableView.clickedRow;
    if(row != -1){
        NSString* folder = self.dataSource[row].simLibPath;
        [[NSWorkspace sharedWorkspace]openFile:folder withApplication:@"Finder"];
    }
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    [self.dataSource removeAllObjects];
    [self findApp];
    [self.tableView reloadData];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
 
}


- (void)findAppWithSimAppModel:(SimAppModel *)model
{
    NSArray *array2 = [model.simAppPath componentsSeparatedByString:@"data/Containers"];
    if(array2.count == 2){
        NSString *simulatorPlist = [array2[0] stringByAppendingString:@"device.plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:simulatorPlist];
        if(dict){
           model.simulatorDeviceName = [dict valueForKey:@"name"];
        }
    }
    
    NSArray *arr = [model.simAppPath componentsSeparatedByString:@"Bundle/Application"];
    if(arr.count == 2){
        NSString *prePt = arr[0];
        NSString *dir = [prePt stringByAppendingPathComponent:@"Data/Application"];
        NSError *err =nil;
        NSArray *dirArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:&err];
        for (NSString *item in dirArray) {
            NSString *targeDir = [dir stringByAppendingPathComponent:item];
            NSString *infoPlistPt = [targeDir stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:infoPlistPt];
            if(dict){
                NSString *bundleId =  [dict valueForKey:@"MCMMetadataIdentifier"];
                if(bundleId){
                    if([bundleId isEqualToString:model.simIdentifier])
                    {
                        model.simLibPath = targeDir;
                        [self.dataSource addObject:model];
                    }
                }
            }
        }
    }
}

- (void)findApp{
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/sh";
    task.arguments = @[@"-c", @"ps -ax | grep CoreSimulator/Devices"];
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];
    NSFileHandle *readHandle = [outputPipe fileHandleForReading];
    [task launch];
    [task waitUntilExit];
    NSData *outputData = [readHandle readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    NSArray *arr = [outputString componentsSeparatedByString:@"\n"];
    NSArray *fiffte = [arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF LIKE '*.app*'"]];
    if(fiffte){
        for (NSString * pt1 in fiffte) {
           
            NSRange range = [pt1 rangeOfString:@"/" options:NSCaseInsensitiveSearch];
            if(range.length == 1){
                NSString *bundleId =  nil;
                NSString *pt = [[pt1 substringFromIndex:range.location] stringByDeletingLastPathComponent];
                NSError *err;
                NSArray *array = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:pt error:&err];
                NSArray *fiffte2 = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF LIKE[c] 'info.plist'"]];
                for (NSString *_item in fiffte2) {
                    NSString *infoPlistPt =  [pt stringByAppendingPathComponent:_item];
                    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:infoPlistPt];
                    bundleId =  [dict valueForKey:@"CFBundleIdentifier"];
                    if(bundleId.length > 0){
                        SimAppModel *model = [[SimAppModel alloc] init];
                        model.simAppPath = pt;
                        model.simIdentifier = bundleId;
                        model.simAppName = [dict valueForKey:@"CFBundleExecutable"];
                        
                        NSArray *arrIcon = [dict valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"];
                        for (NSString *strIcon in arrIcon) {
                            NSString *iconPt = [[pt stringByAppendingPathComponent:strIcon] stringByAppendingString:@"@2x.png"];
                            if([[NSFileManager defaultManager] fileExistsAtPath:iconPt]){
                               NSImage *image  = [[NSImage alloc] initWithContentsOfFile:iconPt];
                                model.simAppIcon = image;
                                if(image.size.width > 40)
                                {
                                    break;
                                }
                               
                            }
                        }
                       
                        if(model !=nil && model.simAppIcon == nil  )
                        {
                             NSString *iconFile = [dict valueForKey:@"CFBundleIconFile"];
                             if(iconFile){
                                 NSString *iconPt = [pt stringByAppendingPathComponent:iconFile];
                                 NSImage *image  = [[NSImage alloc] initWithContentsOfFile:iconPt];
                                 model.simAppIcon = image; 
                             }
                        }
                        [self findAppWithSimAppModel:model];
                        break;
                    }
                }
            }
        }
    }
}
#pragma mark - datasource
- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.dataSource.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    SimAppCellView *cell = [tableView makeViewWithIdentifier:reUserId owner:nil];
    cell.appModel = self.dataSource[row];
    return cell;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 60;
}



- (NSMutableArray<SimAppModel *> *)dataSource
{
    if(_dataSource == nil){
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (IBAction)exitBtnClick:(id)sender {
    exit(0);
}


@end
