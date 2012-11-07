//
//  COSMDefaults.m
//  NYCSound
//
//  Created by Ross Cairns on 07/11/2012.
//  Copyright (c) 2012 COSM. All rights reserved.
//

#import "COSMDefaults.h"

@implementation COSMDefaults

static COSMDefaults *sharedInstance = nil;
static NSDictionary *colorDictionary;

+ (COSMDefaults *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[COSMDefaults alloc] init];
        
        colorDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                           // orange
                           [UIColor colorWithRed:241.0f/255.0f green:89.0f/255.0f blue:42.0f/255.0f alpha:1.0f], @"orange",
                           // cosm grey
                           [UIColor colorWithRed:175.0f/255.0f green:178.0f/255.0f blue:179.0f/255.0f alpha:1.0f], @"grey",
                           // cosm grey
                           [UIColor colorWithRed:156.0f/255.0f green:155.0f/255.0f blue:155.0f/255.0f alpha:1.0f], @"light grey",
                           nil];
        
    });
    return sharedInstance;
}

+ (UIColor *)colorForKey:(NSString *)key {
    if (!sharedInstance) { [COSMDefaults sharedInstance]; }
    return (UIColor *) [colorDictionary objectForKey:key];
}

@end
