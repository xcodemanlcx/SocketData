//
//  ViewController.m
//  SocketData
//
//  Created by lcx on 2019/11/22.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "ViewController.h"
#import "YMSocketUtils.h"
#import "SocketDataUtil.h"

#import <objc/runtime.h>


@interface ClientModel : NSObject

@property (nonatomic, assign) uint8_t  sceneId;
@property (nonatomic, copy) NSString *message;

@end

@implementation ClientModel

@end

@interface ViewController ()

@property (nonatomic,strong) NSMutableData *data;
@property (nonatomic,strong) id object;

@property (nonatomic,strong) NSMutableData *cacheData;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _cacheData = [NSMutableData data];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    ClientModel * clientModel = [ClientModel new];
    clientModel.sceneId = 12;
    clientModel.message = @"大家好哦~";
    
    //封包
    self.object = [SocketDataUtil dealwithData:_data withObj:clientModel];
    
    // 创建了这个模型实例数据包之后，通过某种方法把它通过Socket发出去

}

//拆包
-(void) didReadData:(NSData *)data {
    
    //将接收到的数据保存到缓存数据中
    [self.cacheData appendData:data];;
    
    // 取出4-8位保存的数据长度，计算数据包长度
    NSData *dataLength = [_cacheData subdataWithRange:NSMakeRange(4, 4)];
    int dataLenInt = CFSwapInt32BigToHost(*(int*)([dataLength bytes]));
    NSInteger lengthInteger = 0;
    lengthInteger = (NSInteger)dataLenInt;
    NSInteger complateDataLength = lengthInteger + 8;//算出一个包完整的长度(内容长度＋头长度)
    NSLog(@"data = %ld  ----   length = %d  ",data.length,dataLenInt);
    
    //因为服务号和长度字节占8位，所以大于8才是一个正确的数据包
    while (_cacheData.length > 8) {
        
        if (_cacheData.length < complateDataLength) { //如果缓存中的数据长度小于包头长度 则继续拼接
            
            /*
            [[SingletonSocket sharedInstance].socket readDataWithTimeout:-1 tag:0];//socket读取数据
             */
            break;
            
        }else {
            
            //截取完整数据包
            NSData *dataOne = [_cacheData subdataWithRange:NSMakeRange(0, complateDataLength)];
            /*
            [self handleTcpResponseData:dataOne];//处理包数据
             NSData *contenData = [data subdataWithRange:NSMakeRange(8, data.length-8)];
             // 取出4-8位保存的数据长度
             
             NSString *dataStr_8 = [[NSString alloc] initWithData:contenData encoding:NSUTF8StringEncoding];
             */
            NSData *contenData = [data subdataWithRange:NSMakeRange(8, data.length-8)];
            // 取出4-8位保存的数据长度
            
            NSString *dataStr_8 = [[NSString alloc] initWithData:contenData encoding:NSUTF8StringEncoding];
            
            [_cacheData replaceBytesInRange:NSMakeRange(0, complateDataLength) withBytes:nil length:0];
            
            if (_cacheData.length > 8) {
                
                [self didReadData:nil];
                
            }
        }
    }
}

@end
