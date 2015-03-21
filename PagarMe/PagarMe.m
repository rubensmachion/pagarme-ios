//
//  PagarMe.m
//  PagarMe
//
//  Created by Pedro Franceschi on 5/3/13.
//  Copyright (c) 2013 PagarMe. All rights reserved.
//

#import "PagarMe.h"

@implementation PagarMe

static PagarMe *sharedInstance = nil;

+ (PagarMe *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
 
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[PagarMe alloc] init];
    });
 
    return sharedInstance;
}

@end
