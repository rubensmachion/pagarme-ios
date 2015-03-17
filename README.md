# PagarMe

### Installation with CocoaPods
    pod "PagarMe"

### How To

##### Add to `AppDelegate.m` - `didFinishLaunchingWithOptions`
```objc
    [PagarMe sharedInstance].encryptionKey = @"Your_PagarMe_EncryptionKey";
```
    
##### Usage
```objc
    PagarMeCreditCard *pagarMeCreditCard = [[PagarMeCreditCard alloc] initWithCardNumber:_tfCardNumber.text cardHolderName:_tfCardHolderName.text cardExpirationMonth:_cardExpirationMonth cardExpirationYear:_cardExpirationYear cardCvv:_tfCardCVC.text];

    if ([pagarMeCreditCard hasErrorCardNumber]) {
        // Error with CardNumber
    }
    else if ([pagarMeCreditCard hasErrorCardHolderName]) {
        // Error with CardHolderName
    }
    else if ([pagarMeCreditCard hasErrorCardCVV]) {
        // Error with CardCVV
    }
    else if ([pagarMeCreditCard hasErrorCardExpirationMonth]) {
        // Error with CardExpirationMonth
    }
    else if ([pagarMeCreditCard hasErrorCardExpirationYear]) {
        // Error with CardExpirationYear
    }
    else {
        // Validated all Fields!
        [pagarMeCreditCard generateHash:^(NSError *error, NSString *cardHash) {
            if(error) {
                NSLog(@"Error: %@", error);
                return;
            }
            NSLog(@"CardHash Generated: %@", cardHash);
        }];
    }
```
