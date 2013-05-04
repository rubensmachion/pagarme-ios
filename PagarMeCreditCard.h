//
//  PagarMeCreditCard.h
//  PagarMe
//
//  Created by Pedro Franceschi on 5/3/13.
//  Copyright (c) 2013 PagarMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PagarMeCreditCard : NSObject <NSURLConnectionDelegate> {
	NSMutableData *responseData;
}

- (id)initWithCardNumber:(NSString *)_cardNumber cardHolderName:(NSString *)_cardHolderName cardExpiracyMonth:(int)_cardExpiracyMonth
cardExpiracyYear:(int)_cardExpiracyYear cardCvv:(int)_cardCvv;
- (void)generateHash:(void (^)(NSError *error, NSString *cardHash))block;

@property (retain) NSString *cardNumber;
@property (retain) NSString *cardHolderName;
@property (assign) int cardExpiracyMonth;
@property (assign) int cardExpiracyYear;
@property (retain) NSString *cardCvv;

@end
