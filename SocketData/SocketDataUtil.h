//
//  SocketDataUtil.h
//  SocketData
//
//  Created by leichunxiang on 2019/11/24.
//  Copyright © 2019 lcx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketDataUtil : NSObject

//封包
+(NSMutableData *)dealwithData:(NSMutableData *)data withObj:(id)obj;

//封包：
+ (NSData *)packingWtihData:(NSData *)data type:(NSUInteger )type;

//拆包
+ (void)unpackingData:(NSData *)data withCacheData:(NSMutableData *)cacheData socketReadDataBlock:(dispatch_block_t)socketReadDataBlock
socketHandleDataBlock:(void (^)(unsigned int serviceID,NSData *contentData))socketHandleDataBlock;

@end

NS_ASSUME_NONNULL_END
