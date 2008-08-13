//
//  SFCardDB.h
//  SuicaExample
//
//  Created by GNUE(鵺) on 08/04/11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SFCardDB : NSObject {
}

+ (SFCardDB*)sharedSFCardDB;

- (NSDictionary *)getStationNameWithAreaCode:(int)areaCode lineCode:(int)lineCode stationCode:(int)stationCode;
- (NSDictionary *)getStationNameWithStation:(uint8_t *)station regionCode:(int)region;


@end
