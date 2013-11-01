//
//  PagarMe.h
//  PagarMe
//
//  Created by Pedro Franceschi on 5/3/13.
//  Copyright (c) 2013 PagarMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagarMeCreditCard.h"

#define API_ENDPOINT @"https://api.pagar.me/1"

@interface PagarMe : NSObject

@property (retain) NSString *encryptionKey;

+ (PagarMe *)sharedInstance;

@end
