//
//  Utils.m
//  NYCSound
//
//  Created by Ross Cairns on 12/11/2012.
//  Copyright (c) 2012 COSM. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (void)alert:(NSString *)title message:(NSString *)messageOrNil {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:title
                                                      message:messageOrNil
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

@end
