//  PagarMeCreditCard.m
//  PagarMe
//
//  Created by Pedro Franceschi on 5/3/13.
//  Copyright (c) 2013 PagarMe. All rights reserved.
//

#import <Security/Security.h>
#import "PagarMeCreditCard.h"
#import "PagarMe.h"
#import "NSData+Base64.h"

@implementation PagarMeCreditCard

@synthesize cardNumber, cardHolderName, cardExpirationMonth, cardExpirationYear, cardCvv;

- (id)initWithCardNumber:(NSString *)_cardNumber cardHolderName:(NSString *)_cardHolderName
cardExpirationMonth:(int)_cardExpirationMonth cardExpirationYear:(int)_cardExpirationYear cardCvv:(NSString *)_cardCvv {
	self.cardNumber = _cardNumber;
	self.cardHolderName = _cardHolderName;
	self.cardExpirationMonth = _cardExpirationMonth;
	self.cardExpirationYear = _cardExpirationYear;
	self.cardCvv = _cardCvv;

	return self;
}

- (void)generateHash:(void (^)(NSError *error, NSString *cardHash))block {
	self.callbackBlock = block;
	NSString *urlString = [NSString stringWithFormat:@"%@/transactions/card_hash_key?encryption_key=%@", API_ENDPOINT, [[PagarMe sharedInstance] encryptionKey]];
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"GET"];

	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (NSString *)cardHashString {
	NSMutableArray *parameters = [[NSMutableArray alloc] init];

	[parameters addObject:[NSString stringWithFormat:@"card_number=%@", self.cardNumber]];
	[parameters addObject:[NSString stringWithFormat:@"card_holder_name=%@", self.cardHolderName]];
	[parameters addObject:[NSString stringWithFormat:@"card_expiration_date=%02i%02i", self.cardExpirationMonth, self.cardExpirationYear]];
	[parameters addObject:[NSString stringWithFormat:@"card_cvv=%@", self.cardCvv]];

	return [parameters componentsJoinedByString:@"&"];
}

- (BOOL)isValidCardNumber:(NSString *)cardNumber {
	NSMutableArray *stringAsChars = [[NSMutableArray alloc] initWithCapacity:[cardNumber length]];
	for (int i=0; i < [cardNumber length]; i++) {
		NSString *ichar  = [NSString stringWithFormat:@"%c", [cardNumber characterAtIndex:i]];
		[stringAsChars addObject:ichar];
	}
 
	BOOL isOdd = YES;
	int oddSum = 0;
	int evenSum = 0;

	for (int i = [cardNumber length] - 1; i >= 0; i--) {

		int digit = [(NSString *)[stringAsChars objectAtIndex:i] intValue];

		if (isOdd) 
			oddSum += digit;
		else 
			evenSum += digit/5 + (2*digit) % 10;

		isOdd = !isOdd;				 
	}

	return ((oddSum + evenSum) % 10 == 0);
}

- (NSDictionary *)fieldErrors {
	NSMutableDictionary *fieldErrors = [[NSMutableDictionary alloc] init];

	if(!self.cardNumber || self.cardNumber.length < 16 || self.cardNumber.length > 20 ||
	![self isValidCardNumber:self.cardNumber]) {
		[fieldErrors setObject:@"Número do cartão inválido." forKey:@"card_number"];
	}

	if(!self.cardHolderName || self.cardHolderName.length <= 0 || [self.cardHolderName intValue]) {
		[fieldErrors setObject:@"Nome do portador inválido." forKey:@"card_holder_name"];
	}

	if(self.cardExpirationMonth <= 0 || self.cardExpirationMonth > 12) {
		[fieldErrors setObject:@"Mês de expiração inválido" forKey:@"card_expiration_month"];
	}

	if(self.cardExpirationYear < 1 || self.cardExpirationYear > 50) {
		[fieldErrors setObject:@"Ano de expiração inválido" forKey:@"card_expiration_year"];
	}

	if(self.cardCvv.length < 3 || self.cardCvv.length > 4 || ![self.cardCvv intValue]) {
		[fieldErrors setObject:@"Código de segurança inválido." forKey:@"card_cvv"];
	}

	return fieldErrors;
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
	NSError *error = nil;
	id responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];

	NSLog(@"responseobject: %@", responseObject);

	if(error) {
		self.callbackBlock(error, nil);
		return;
	} else if([responseObject objectForKey:@"errors"]) {
		self.callbackBlock([NSError errorWithDomain:@"Erro de resposta" code:0 userInfo:[[responseObject objectForKey:@"errors"] objectAtIndex:0]], nil);
		return;
	}

	NSString *encryptedString = nil;

	@try {
		encryptedString = [self rsaEncrypt:[self cardHashString] withKey:[responseObject objectForKey:@"public_key"]];
	} @catch (NSException *e) {
		self.callbackBlock(error, nil);
		return;
	}

	self.callbackBlock(nil, [NSString stringWithFormat:@"%@_%@", [responseObject objectForKey:@"id"], encryptedString]);
}
 
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	self.callbackBlock(error, nil);
}

#pragma mark PEM -> DER helpers

- (NSData *)stripPublicKeyHeader:(NSData *)keyData
{
    if (keyData == nil) return(nil);

    unsigned int len = [keyData length];
    if (!len) return(nil);

    unsigned char *c_key = (unsigned char *)[keyData bytes];
    unsigned int  idx    = 0;

    if (c_key[idx++] != 0x30) return(nil);

    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;

    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
     0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);

    idx += 15;

    if (c_key[idx++] != 0x03) return(nil);

    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;

    if (c_key[idx++] != '\0') return(nil);

    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

- (SecKeyRef)parsePublicKey:(NSString *)key
{
	NSString *keyString = [NSString string];
	NSArray  *keyArray = [key componentsSeparatedByString:@"\n"];
	BOOL parsingKey = NO;

	for (NSString *a_line in keyArray) {
		if ([a_line isEqualToString:@"-----BEGIN PUBLIC KEY-----"]) {
			parsingKey = TRUE;
		}
		else if ([a_line isEqualToString:@"-----END PUBLIC KEY-----"]) {
			parsingKey = FALSE;
		}
		else if (parsingKey) {
			keyString = [keyString stringByAppendingString:a_line];
		}
	}

	if(keyString.length == 0) return(nil);

	NSData *keyData = [NSData dataFromBase64String:keyString];
	keyData = [self stripPublicKeyHeader:keyData];
	if (keyData == nil) return(nil);

	// Delete any old lingering key with the same tag
	NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
	[publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
	[publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	[publicKey setObject:@"tag" forKey:(__bridge id)kSecAttrApplicationTag];
	SecItemDelete((__bridge CFDictionaryRef)publicKey);

	CFTypeRef persistKey = nil;

	// Add persistent version of the key to system keychain
	[publicKey setObject:keyData forKey:(__bridge id)kSecValueData];
	[publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
	[publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];

	OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
	if (persistKey != nil) CFRelease(persistKey);

	if ((secStatus != noErr) && (secStatus != errSecDuplicateItem)) {
		return(nil);
	}

	SecKeyRef keyRef = nil;

	[publicKey removeObjectForKey:(__bridge id)kSecValueData];
	[publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
	[publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
	[publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	secStatus = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);

	return keyRef;
}

- (NSString *)rsaEncrypt:(NSString *)string withKey:(NSString *)publicKeyString {
	// Convert input string to a C array of bytes
	NSData *inputData = [string dataUsingEncoding:NSUTF8StringEncoding];
	const void *bytes = [inputData bytes];
	int length = [inputData length];
	uint8_t *plainText = malloc(length);
	memcpy(plainText, bytes, length);

	SecKeyRef publicKey = [self parsePublicKey:publicKeyString];

	// Allocate a buffer to hold the cipher text
	size_t cipherBufferSize;
	uint8_t *cipherBuffer; 
	cipherBufferSize = SecKeyGetBlockSize(publicKey);
	cipherBuffer = malloc(cipherBufferSize);

	SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plainText, length, cipherBuffer, &cipherBufferSize);

	NSData *finalData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];

	// Free used C buffers
	free(cipherBuffer);
	free(plainText);

	return [finalData base64EncodedStringWithSeparateLines:NO];
}

@end
