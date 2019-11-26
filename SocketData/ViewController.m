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
#import <YYModel/YYModel.h>

@interface ClientData : NSObject

@property (nonatomic, assign) uint32_t  serverID;
@property (nonatomic, assign) uint32_t length;
@property (nonatomic, copy) NSString *message;

@end

@implementation ClientData

@end

@interface ClientModel : NSObject

@property (nonatomic, assign) uint8_t  age;
@property (nonatomic, copy) NSString *name;

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
    
    int l1 = sizeof(uint8_t);
    int l2 = sizeof(uint32_t);
    //拆包粘包参考网址
    //https://www.jianshu.com/p/1d290fd22595；
    //socket+protocolbuffer:https://www.cnblogs.com/tandaxia/p/6718695.html
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    ClientModel *clientModel = [ClientModel new];
    clientModel.age = 12;
    clientModel.name = @"张三哦~";
    
    NSString *message = [[NSString alloc] initWithData:clientModel.yy_modelToJSONData encoding:NSUTF8StringEncoding];
    
    ClientData *clientData = [ClientData new];
    clientData.serverID = 1;
    clientData.message = message;
    clientData.length = (int)clientData.message.length;
    
    //封包
    self.object = [SocketDataUtil dealwithData:_data withObj:clientModel];
    self.object = [SocketDataUtil packingWtihData:[@"你好" dataUsingEncoding:NSUTF8StringEncoding] type:1]; 
    
    //拆包
    [SocketDataUtil unpackingData:self.object withCacheData:_cacheData socketReadDataBlock:^{
        //socket继续读取
    } socketHandleDataBlock:^(unsigned int serviceID, NSData * _Nonnull contentData) {
        //数据处理
    }];
}


@end
