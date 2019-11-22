//
//  ViewController.m
//  SocketData
//
//  Created by lcx on 2019/11/22.
//  Copyright © 2019 lcx. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "YMSocketUtils.h"

// 后面NSString这是运行时能获取到的C语言的类型
NSString * const TYPE_UINT8   = @"TC";// char是1个字节，8位
NSString * const TYPE_UINT16   = @"TS";// short是2个字节，16位
NSString * const TYPE_UINT32   = @"TI";
NSString * const TYPE_UINT64   = @"TQ";
NSString * const TYPE_STRING   = @"T@\"NSString\"";
NSString * const TYPE_ARRAY   = @"T@\"NSArray\"";

@interface ClientModel : NSObject

@property (nonatomic, assign) uint8_t  sceneId;
@property (nonatomic, copy) NSString *message;

@end

@implementation ClientModel

@end

@interface ViewController ()

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic,strong)id object;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    ClientModel * clientModel = [ClientModel new];
    clientModel.sceneId = 12;
    clientModel.message = @"大家好哦~";
    // 创建了这个模型实例数据包之后，通过某种方法把它通过Socket发出去
    [self RequestSpliceAttribute:clientModel];
}

-(void)RequestSpliceAttribute:(id)obj{
    if (obj == nil) {
        self.object = _data;
    }
    unsigned int numIvars; //成员变量个数
    
    objc_property_t *propertys = class_copyPropertyList(NSClassFromString([NSString stringWithUTF8String:object_getClassName(obj)]), &numIvars);
    
    NSString *type = nil;
    NSString *name = nil;
    
    for (int i = 0; i < numIvars; i++) {
        objc_property_t thisProperty = propertys[i];
        
        name = [NSString stringWithUTF8String:property_getName(thisProperty)];
        NSLog(@"%d.name:%@",i,name);
        type = [[[NSString stringWithUTF8String:property_getAttributes(thisProperty)] componentsSeparatedByString:@","] objectAtIndex:0]; //获取成员变量的数据类型
        NSLog(@"%d.type:%@",i,type);
        
        id propertyValue = [obj valueForKey:[(NSString *)name substringFromIndex:0]];
        NSLog(@"%d.propertyValue:%@",i,propertyValue);
        
        NSLog(@"\n");
        
        if ([type isEqualToString:TYPE_UINT8]) {
            uint8_t i = [propertyValue charValue];// 8位
            [_data appendData:[YMSocketUtils byteFromUInt8:i]];
        }else if([type isEqualToString:TYPE_STRING]){
            NSData *data = [(NSString*)propertyValue \
                            dataUsingEncoding:NSUTF8StringEncoding];// 通过utf-8转为data
            
            // 用2个字节拼接字符串的长度拼接在字符串data之前
            [_data appendData:[YMSocketUtils bytesFromUInt16:data.length]];
            // 然后拼接字符串
            [_data appendData:data];
            
        }else {
            NSLog(@"RequestSpliceAttribute:未知类型");
            NSAssert(YES, @"RequestSpliceAttribute:未知类型");
        }
    }
    
    // hy: 记得释放C语言的结构体指针
    free(propertys);
    self.object = _data;
}


#pragma mark - 懒加载
- (NSMutableData *)data{
    if (!_data) {
        _data = @[].mutableCopy;
    }
    return _data;
}

@end
