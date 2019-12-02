//
//  SocketDataShareManager.h
//  SocketData
//
//  Created by leichunxiang on 2019/11/24.
//  Copyright © 2019 lcx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketDataShareManager : NSObject

+(instancetype)shareInstance;

//封包
- (NSData *)packingWtihData:(NSData *)data type:(NSUInteger )type;

//拆包
- (void)unpackingData:(NSData *)data socketHandleDataBlock:(void (^)(unsigned int serviceID,NSData *contentData))socketHandleDataBlock;

@end

NS_ASSUME_NONNULL_END
