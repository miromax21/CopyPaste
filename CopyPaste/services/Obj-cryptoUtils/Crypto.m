//
//  Crypto.m
//  MediaMetr
//
//  Created by Maksim Mironov on 08.10.2021.
//  Copyright © 2021 Anitaa. All rights reserved.
//
#import "RSA.h"
#import <NetworkExtension/NEFilterManager.h>

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#include <sys/sysctl.h>
#include <stdlib.h>
#include <syslog.h>
#import "GZIP.h"
#import <UIKit/UIKit.h>
#import "Crypto.h"
@implementation Crypto : NSObject
NSString *pubkey = @"";
NSString *deviceID = @"";
-(id)init :(NSString *) withPubKey :(NSString *) withDeviceID  {
    pubkey      = withPubKey;
    deviceID    = withDeviceID;
    return self;
}

- (NSString *) getDeviceID {
    return deviceID;
}

- (NSData *) getSessionKey {
    NSString *passwordKey = [self getDeviceID];
    passwordKey = [passwordKey stringByAppendingString:@" | whatever key do you want"];
    return [self getCCKey: passwordKey : kCCKeySizeAES256 : 1001];
}

- (NSData *) getIVector {
    NSString *passwordKey = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
    return [self getCCKey: passwordKey : kCCKeySizeAES128 : 330];
}

- (NSData *) my_encryptData:(NSData *)J0 {
   NSData *SK0 = [self getSessionKey];
   NSData *IV0 = [self getIVector];
   NSData *SK1 = [self getRSA:SK0];
   NSData *IV1 = [self getRSA:IV0];
   NSData *JD0 = [self getSHA256:J0];
   NSData *JD1 = [self getRSA:JD0];
   NSData *JG0 = [J0 gzippedData];
   NSMutableData *B= [NSMutableData dataWithData:JG0];
   [B appendData:JD0];
   NSData *D = [self getAES:SK0 :IV0 :B];
 
   if (SK1!=nil && IV1!=nil && JD1!=nil && D!=nil) {
   
       NSDictionary *JOUT =[NSDictionary dictionaryWithObjectsAndKeys:
                        [SK1 base64EncodedStringWithOptions:0], @"SK1",
                        [IV1 base64EncodedStringWithOptions:0], @"IV1",
                        [JD1 base64EncodedStringWithOptions:0], @"JD1",
                        [D   base64EncodedStringWithOptions:0], @"DATA",
                        nil];
   
   
       NSData *JOUT0 = [NSJSONSerialization dataWithJSONObject:JOUT options:NSJSONWritingPrettyPrinted error:nil];
       NSData *JOUT1 = [JOUT0 gzippedData];
       
       return JOUT1;
   } else {
       return (nil);
   }
}

- (NSData *) getRSA:(NSData *)data {
   return ([RSA encryptData:data publicKey:pubkey]);
}

- (NSData *) getSHA256:(NSData *)dataIn {
   unsigned char hash[CC_SHA256_DIGEST_LENGTH];
   CC_SHA256([dataIn bytes], (uint32_t) [dataIn length], hash);
   NSData *dataOut = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
   return dataOut;
}

- (NSData *) getAES:(NSData *)key :(NSData *)iv :(NSData *)dataIn {
   CCCryptorRef cryptor;
   CCCryptorStatus result = CCCryptorCreateWithMode(kCCEncrypt,
                                                    kCCModeCBC,
                                                    kCCAlgorithmAES,
                                                    kCCOptionPKCS7Padding,
                                                    [iv bytes],
                                                    [key bytes],
                                                    kCCKeySizeAES256,
                                                    NULL,
                                                    0,
                                                    0,
                                                    0,
                                                    &cryptor);
   
   size_t bufferLength = CCCryptorGetOutputLength(cryptor, [dataIn length], true);
   NSMutableData *dataOut = [NSMutableData dataWithLength:bufferLength];
   NSMutableData *cipherData = [NSMutableData data];
   size_t outLength;
   result = CCCryptorUpdate(cryptor,
                            [dataIn bytes],
                            [dataIn length],
                            [dataOut mutableBytes],
                            [dataOut length],
                            &outLength);
   [cipherData appendBytes:dataOut.bytes length:outLength];
   
   result = CCCryptorFinal(cryptor,
                           [dataOut mutableBytes],
                           [dataOut length],
                           &outLength);
   [cipherData appendBytes:dataOut.bytes length:outLength];
   
   CCCryptorRelease(cryptor);
   return cipherData;
}

- (NSData *) getCCKey: (NSString *) passwordKey : (int) keySize : (int) rounds{
   uint8_t saltKey[32];
   int result = SecRandomCopyBytes(kSecRandomDefault, 32, saltKey);
   NSData *passwordData = [passwordKey dataUsingEncoding:NSUTF8StringEncoding];
   NSData *salt = [NSData dataWithBytes:saltKey length:sizeof(saltKey)];
   NSMutableData *derivedKey = [NSMutableData dataWithLength:  keySize];
   
   result = CCKeyDerivationPBKDF(kCCPBKDF2,
                                 passwordData.bytes,
                                 passwordData.length,
                                 salt.bytes,
                                 salt.length,
                                 kCCPRFHmacAlgSHA1,
                                 rounds,
                                 derivedKey.mutableBytes,
                                 derivedKey.length);
   return (derivedKey);
}

@end
