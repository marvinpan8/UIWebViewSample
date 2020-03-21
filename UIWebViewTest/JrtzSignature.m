#import <CommonCrypto/CommonHMAC.h>
#import "JrtzSignature.h"
 
@implementation JrtzSignature

// ID和 KEY由今日投资分配，券商自己负责保管好，防止泄露
// NSString *const SECRET_ID = @"IDIDIDIDIDIDIDIDIDIDIDIDIDIIDID";
// static NSString *const SECRET_KEY = @"KEYKEYKEYKEYKEYKEYKEYKEYKEYKEYKEY";

NSString *const SECRET_ID = @"nT3GoChoSilVSWskjjCxEKA1G8R6otAO";
static NSString *const SECRET_KEY = @"ZWqy9tQXHVzwOvBULX5GS0QWjv7E8Bz8";

+ (NSString *)jrtzSignatureWithCurrentDateUTC:(NSString *)currentDateUTC Product:(NSString *)product StringToSign:(NSString *)stringToSign 
{
    NSData *keyData = [[NSString stringWithFormat:@"JC1%@", SECRET_KEY] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secretDate = [JrtzSignature hmacSHA256WithSecret:keyData Content:currentDateUTC];
    NSData *secretService = [JrtzSignature hmacSHA256WithSecret:secretDate Content:product];
    NSData *secretSigning = [JrtzSignature hmacSHA256WithSecret:secretService Content:@"jc1_request"];
    NSData *signData = [JrtzSignature hmacSHA256WithSecret:secretSigning Content:stringToSign];

    const unsigned char *buffer = (const unsigned char *)[signData bytes];
    NSMutableString *signature = [NSMutableString stringWithCapacity:signData.length * 2];
    for (int i = 0; i < signData.length; ++i){
        [signature appendFormat:@"%02x", buffer[i]];
    }
    NSLog(@"signature:%@", signature);
    return signature;
}

+ (NSData *)hmacSHA256WithSecret:(NSData *)secret Content:(NSString *)content
{
    const char *cData = [content cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, secret.bytes, secret.length, cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    return HMACData;
}

@end
