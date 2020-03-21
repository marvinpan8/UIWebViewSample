//
//  今日投资云API签名工具  
//
//  Created by marvinpan on 2020-03-12.
//  Copyright © 2020 All rights reserved.
//
#import <UIKit/UIKit.h>

@interface JrtzSignature: UIViewController

extern NSString *const SECRET_ID;

+ (NSString *)jrtzSignatureWithCurrentDateUTC:(NSString *)currentDateUTC Product:(NSString *)product StringToSign:(NSString *)stringToSign;
+ (NSData *)hmacSHA256WithSecret:(NSData *)secret Content:(NSString *)content;

@end