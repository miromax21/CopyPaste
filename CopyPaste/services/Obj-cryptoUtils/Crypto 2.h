//
//  Crypto.h
//  MediaMetr
//
//  Created by Maksim Mironov on 08.10.2021.
//  Copyright © 2021 Anitaa. All rights reserved.
//

#ifndef Crypto_h
#define Crypto_h


#endif /* Crypto_h */
@interface Crypto : NSObject
- (id) init :(NSString *) withPubKey :(NSString *) withDeviceID;
- (NSData *) my_encryptData:(NSData *)J0;
@end
