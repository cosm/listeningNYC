//
//  COSMDefaults.h
//  NYCSound
//
//  Created by Ross Cairns on 07/11/2012.
//  Copyright (c) 2012 COSM. All rights reserved.
//

#import <Foundation/Foundation.h>

// Singleton
@interface COSMDefaults : NSObject;

// should not be needed
+ (COSMDefaults *)sharedInstance;

+ (UIColor *)colorForKey:(NSString *)key;
+ (NSString *)cosmGUID;


@end
