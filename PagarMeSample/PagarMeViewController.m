//
//  PagarMeViewController.m
//  PagarMe
//
//  Created by Pedro Franceschi on 5/3/13.
//  Copyright (c) 2013 PagarMe. All rights reserved.
//

#import "PagarMeViewController.h"
#import "PagarMe.h"

@interface PagarMeViewController ()

@end

@implementation PagarMeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	// Sets your encryption key
	[[PagarMe sharedInstance] setEncryptionKey:@"ek_test_Ec8KhxISQ1tug1b8bCGxC2nXfxqRmk_"];

	PagarMeCreditCard *creditCard = [[PagarMeCreditCard alloc] init];
	creditCard.cardNumber = @"4901720080344448";
	creditCard.cardHolderName = @"Test User";
	creditCard.cardExpirationMonth = 12;
	creditCard.cardExpirationYear = 13;
	creditCard.cardCvv = @"315";

	NSDictionary *errors = [creditCard fieldErrors];

	if([errors count] != 0) {
		NSLog(@"Foram encontrados erros validando os dados do cartão de crédito: ");
		NSLog(@"%@", errors);
	} else {
		[creditCard generateHash:^(NSError *error, NSString *cardHash) {
			NSLog(@"GOT CARD HASH: %@", cardHash);
			NSLog(@"ERROR? %@", error);
		}];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
