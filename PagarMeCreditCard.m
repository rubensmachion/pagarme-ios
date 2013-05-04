//
//  PagarMeCreditCard.m
//  PagarMe
//
//  Created by Pedro Franceschi on 5/3/13.
//  Copyright (c) 2013 PagarMe. All rights reserved.
//

#import "PagarMeCreditCard.h"
#import "PagarMe.h"

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

- (void)generateHash:(void (^)(NSError *error, NSString *cardHash))block {
	NSString *urlString = [NSString stringWithFormat:@"%@/transactions/card_hash_key?encryption_key=%@", API_ENDPOINT, [[PagarMe sharedInstance] encryptionKey]];
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"GET"];

	NSLog(@"urlString: %@", urlString);

	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	responseData = [[NSMutableData alloc] init];
}
 
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}
 
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection 
    return nil;
}
 
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
	NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSLog(@"response string: %@", response);
}
 
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
	NSLog(@" error: %@", error);
}

@end


// TODO: remove in production!
// This trusts any HTTPS certificate
// for test purposes only!
@implementation NSURLRequest(AllowAllCerts)

+ (BOOL) allowsAnyHTTPSCertificateForHost:(NSString *) host {
    return YES;
}

@end
