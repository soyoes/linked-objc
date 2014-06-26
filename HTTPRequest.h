//
//  HTTPRequest.h
//  liberobjc
//
//  Created by @soyoes on 10/29/12.
//  Copyright (c) 2012 Liberhood ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^HTTPRequestHandler)(id, NSDictionary*);

@interface HTTPRequest : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (nonatomic, retain)   NSMutableData       *raw;
@property (nonatomic, copy)     HTTPRequestHandler  handler;
@property (nonatomic, retain)   NSMutableDictionary   *datas;

+ (void)get:(NSString *)url handler:(HTTPRequestHandler)handler datas:(NSDictionary*)datas;
+ (void)post:(NSString *)url params:(NSDictionary*)params handler:(HTTPRequestHandler)handler datas:(NSDictionary*)datas;

//+ (NSString *)packImage :(UIImage *)image;

@end


