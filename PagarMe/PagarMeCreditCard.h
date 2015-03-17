//
//  PagarMeCreditCard.h
//  PagarMe
//
//  Created by Pedro Franceschi on 5/3/13.
//  Updated by Luciano Nascimento on 17/3/15.
//  Copyright (c) 2013 PagarMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PagarMeCreditCard : NSObject

- (id)initWithCardNumber:(NSString *)cardNumber cardHolderName:(NSString *)cardHolderName
     cardExpirationMonth:(NSString *)cardExpirationMonth cardExpirationYear:(NSString *)cardExpirationYear cardCvv:(NSString *)cardCvv;
- (BOOL)hasErrorCardNumber;
- (BOOL)hasErrorCardHolderName;
- (BOOL)hasErrorCardExpirationMonth;
- (BOOL)hasErrorCardExpirationYear;
- (BOOL)hasErrorCardCVV;
- (void)generateHash:(void (^)(NSError *error, NSString *cardHash))block;

@end
