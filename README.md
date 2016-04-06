# PagarMe

### Installation with CocoaPods
    pod "PagarMe"

### How To

##### Add to `AppDelegate.m` - `didFinishLaunchingWithOptions`
```objc
[[PagarMe sharedInstance] setEncryptionKey:@"Your_PagarMe_EncryptionKey"];
```
    
##### Usage
```objc
PagarMeCreditCard *pagarMeCreditCard = [[PagarMeCreditCard alloc] initWithCardNumber:@"4111111111111111" cardHolderName:@"Test Card" cardExpirationMonth:@"10" cardExpirationYear:@"20" cardCvv:@"123"];

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

## Support
If you have any problem or suggestion please open an issue [here](https://github.com/pagarme/pagarme-ios/issues).

## License

Check [here](LICENSE).
