//
//  PagarMe.m
//  PagarMe
//
//  Created by Pedro Franceschi on 5/3/13.
//  Copyright (c) 2013 PagarMe. All rights reserved.
//

#import "PagarMe.h"

#define API_ENDPOINT @"https://0.0.0.0:3001/1"

@implementation PagarMe

@synthesize encryptionKey, liveMode;

static PagarMe *sharedInstance = nil;

+ (PagarMe *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
 
	// Thread safe singleton...
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[PagarMe alloc] init];
    });
 
    return sharedInstance;
}

@end
