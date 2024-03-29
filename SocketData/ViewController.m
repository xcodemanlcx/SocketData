//
//  ViewController.m
//  SocketData
//
//  Created by lcx on 2019/11/22.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "ViewController.h"
#import "SocketDataShareManager.h"

@interface ViewController ()

@property (nonatomic,strong) NSData *data;
@property (nonatomic,assign) NSUInteger sendeDataLength;
@property (nonatomic,strong) NSMutableData *cacheData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - 封包、启动通信

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //封包
    _data = [[SocketDataShareManager shareInstance]  packingWtihData:[@"会当水击三千里，自信人生二百年！雄光漫道真如铁，而今迈步从头越！" dataUsingEncoding:NSUTF8StringEncoding] type:1];
    _sendeDataLength = 0;
    //发包
    [self sendRandomData:[self randomData]];
}

#pragma mark - socket通信：用不确定长度的随机包模拟

//发包
- (void)sendRandomData:(NSData *)data{
    if (_sendeDataLength < _data.length) {
        //拆包
        [self unpackingData:data];
    }
}

//随机包
- (NSData *)randomData{
    NSUInteger dataLength = arc4random()%8;
    if(dataLength == 0) dataLength = 1;
    if (dataLength > _data.length - _sendeDataLength) {
        dataLength = _data.length - _sendeDataLength;
    }
    NSData *randomData = [_data subdataWithRange:NSMakeRange(_sendeDataLength, dataLength)];
    return randomData;
}

#pragma mark - 拆包

//拆包
- (void )unpackingData:(NSData *)data{
    //记录已发送长度
    _sendeDataLength += data.length;

    //拆包
    [[SocketDataShareManager shareInstance] unpackingData:data socketHandleDataBlock:^(unsigned int serviceID, NSData * _Nonnull contentData) {
       
        //长度足够，完整数据处理
        NSLog(@"拆包：serviceID == %ul,contentData string == %@",serviceID,[[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding]);
    }];
   
    //长度不够，继续读取，拼接完整数据
    [self sendRandomData:[self randomData]];
}

@end
