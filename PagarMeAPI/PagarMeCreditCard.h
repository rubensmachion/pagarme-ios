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

- (id)initWithCardNumber:(NSString *)_cardNumber cardHolderName:(NSString *)_cardHolderName cardExpirationMonth:(int)_cardExpirationMonth
cardExpirationYear:(int)_cardExpirationYear cardCvv:(int)_cardCvv;
- (void)generateHash:(void (^)(NSError *error, NSString *cardHash))block;
- (NSDictionary *)fieldErrors;

@property (retain) NSString *cardNumber;
@property (retain) NSString *cardHolderName;
@property (assign) int cardExpirationMonth;
@property (assign) int cardExpirationYear;
@property (retain) NSString *cardCvv;
@property (copy) void (^callbackBlock)(NSError *error, NSString *cardHash);

@end
