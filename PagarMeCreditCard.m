//
//  PagarMeCreditCard.m
//  PagarMe
//
//  Created by Pedro Franceschi on 5/3/13.
//  Copyright (c) 2013 PagarMe. All rights reserved.
//

#import "PagarMeCreditCard.h"

@implementation PagarMeCreditCard

@synthesize cardNumber, cardHolderName, cardExpiracyMonth, cardExpiracyYear, cardCvv;

- (id)initWithCardNumber:(NSString *)_cardNumber cardHolderName:(NSString *)_cardHolderName
cardExpiracyMonth:(int)_cardExpiracyMonth cardExpiracyYear:(int)_cardExpiracyYear cardCvv:(NSString *)_cardCvv {
	self.cardNumber = _cardNumber;
	self.cardHolderName = _cardHolderName;
	self.cardExpiracyMonth = _cardExpiracyMonth;
	self.cardExpiracyYear = _cardExpiracyYear;
	self.cardCvv = _cardCvv;

	return self;
}

@end
