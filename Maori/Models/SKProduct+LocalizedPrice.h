//
//  SKProduct+LocalizedPrice.h
//  SoHo
//
//  Created by Dat Truong on 3/2/14.
//  Copyright (c) 2014 Dat Anh Truong. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)
@property (nonatomic, readonly) NSString *localizedPrice;
@end
