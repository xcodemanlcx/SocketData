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

@end

NS_ASSUME_NONNULL_END
