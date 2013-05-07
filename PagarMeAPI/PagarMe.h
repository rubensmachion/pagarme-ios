//
//  PagarMe.h
//  PagarMe
//
//  Created by Pedro Franceschi on 5/3/13.
//  Copyright (c) 2013 PagarMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagarMeCreditCard.h"

#define API_ENDPOINT @"https://0.0.0.0:3001/1"

@interface PagarMe : NSObject

@property (retain) NSString *encryptionKey;
@property (assign) BOOL liveMode;

+ (PagarMe *)sharedInstance;

@end
