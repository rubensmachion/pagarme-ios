//
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
	self.callbackBlock = block;
	NSString *urlString = [NSString stringWithFormat:@"%@/transactions/card_hash_key?encryption_key=%@&live=%@", API_ENDPOINT,
		 [[PagarMe sharedInstance] encryptionKey], [[PagarMe sharedInstance] liveMode] ? @"1" : @"0"];
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"GET"];

	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (NSData *)stripPublicKeyHeader:(NSData *)d_key
{
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);

    unsigned int len = [d_key length];
    if (!len) return(nil);

    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx    = 0;

    if (c_key[idx++] != 0x30) return(nil);

    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;

    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
     0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);

    idx += 15;

    if (c_key[idx++] != 0x03) return(nil);

    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;

    if (c_key[idx++] != '\0') return(nil);

    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

- (SecKeyRef)parsePublicKey:(NSString *)key
{
    NSString *s_key = [NSString string];
    NSArray  *a_key = [key componentsSeparatedByString:@"\n"];
    BOOL     f_key  = FALSE;

    for (NSString *a_line in a_key) {
        if ([a_line isEqualToString:@"-----BEGIN PUBLIC KEY-----"]) {
            f_key = TRUE;
        }
        else if ([a_line isEqualToString:@"-----END PUBLIC KEY-----"]) {
            f_key = FALSE;
        }
        else if (f_key) {
            s_key = [s_key stringByAppendingString:a_line];
        }
    }
    if (s_key.length == 0) return(nil);

    // This will be base64 encoded, decode it.
    NSData *d_key = [NSData dataFromBase64String:s_key];
    d_key = [self stripPublicKeyHeader:d_key];
    if (d_key == nil) return(nil);

    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:@"tag" forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);

    CFTypeRef persistKey = nil;

    // Add persistent version of the key to system keychain
    [publicKey setObject:d_key forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)
     kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
     kSecReturnPersistentRef];

    OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil) CFRelease(persistKey);

    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem)) {
        return(nil);
    }

    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;

    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    secStatus = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey,
                                    (CFTypeRef *)&keyRef);

	return keyRef;

    /* if (keyRef == nil) return(FALSE); */

    /* // Add to our pseudo keychain */
    /* [keyRefs addObject:[NSValue valueWithBytes:&keyRef objCType:@encode( */
    /*                         SecKeyRef)]]; */
}

- (NSString *)rsaEncrypt:(NSString *)string withKey:(NSString *)publicKeyString {
	NSData *inputData = [string dataUsingEncoding:NSUTF8StringEncoding];
	const void *bytes = [inputData bytes];
	int length = [inputData length];
	uint8_t *plainText = malloc(length);
	memcpy(plainText, bytes, length);

	NSLog(@"publicKeyString: %@", publicKeyString);

	SecKeyRef publicKey = [self parsePublicKey:publicKeyString];
	NSLog(@"publicKey: %i", publicKey);

	/* allocate a buffer to hold the cipher text */
	size_t cipherBufferSize;
	uint8_t *cipherBuffer; 
	cipherBufferSize = SecKeyGetBlockSize(publicKey);
	cipherBuffer = malloc(cipherBufferSize);

	/* encrypt!! */
	SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plainText, length, cipherBuffer, &cipherBufferSize);


	NSData *finalData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];

	NSLog(@"finalData: %@", finalData);

	/* Free the Security Framework Five! */
	free(cipherBuffer);

	/* And this guy if you used #2 above (got your plain text from an NSString) */
	free(plainText);

	return [finalData base64EncodedStringWithSeparateLines:NO];
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

	NSLog(@"id: %@", [responseObject objectForKey:@"id"]);

	if(error) {
		self.callbackBlock(error, nil);
		return;
	}

	NSLog(@"rsaEncrypt: %@", [self rsaEncrypt:@"card_number=121212121212&card_holder_name=asd&card_expiracy_date=1213&card_cvv=123" withKey:[responseObject objectForKey:@"public_key"]]);
}
 
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	self.callbackBlock(error, nil);
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
