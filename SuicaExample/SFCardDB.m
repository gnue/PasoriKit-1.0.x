//
//  SFCardDB.m
//  SuicaExample
//
//  Created by GNUE(鵺) on 08/04/11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PasoriKit/suica.h"
#import "SFCardDB.h"


NSString * const	kParamAreaCode = @"AreaCode";
NSString * const	kParamLineCode = @"LineCode";
NSString * const	kParamStationCode = @"StationCode";


static SFCardDB *	sharedSFCardDB = nil;


@implementation SFCardDB

+ (SFCardDB*)sharedSFCardDB
{
    @synchronized(self) {
        if (sharedSFCardDB == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return sharedSFCardDB;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedSFCardDB == nil) {
            sharedSFCardDB = [super allocWithZone:zone];
            return sharedSFCardDB;  // 最初の割り当てで代入し、返す
        }
    }
    return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
 
- (id)retain
{
    return self;
}
 
- (unsigned)retainCount
{
    return UINT_MAX;  // 解放できないオブジェクトであることを示す
}
 
- (void)release
{
    // 何もしない
}
 
- (id)autorelease
{
    return self;
}


#pragma mark -


/// SOAP を使って駅名を取得する
- (NSDictionary *)getStationNameWithAreaCode:(int)areaCode lineCode:(int)lineCode stationCode:(int)stationCode
{
	NSURL *		url = [NSURL URLWithString:@"http://www.denno.net/SFCardFan/soapserver.php"];
	NSString *	method = @"getStationName";
	NSString *	namespace = @"http://www.denno.net/SFCardFan/sfcardfandb.wsdl";

	// SOAP request params
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithUnsignedShort:areaCode], kParamAreaCode,
							[NSNumber numberWithUnsignedShort:lineCode], kParamLineCode,
							[NSNumber numberWithUnsignedShort:stationCode], kParamStationCode,
							nil];
	
	NSArray *paramOrder = [NSArray arrayWithObjects:kParamAreaCode, kParamLineCode, kParamStationCode, nil];

	// SOAP request http headers -- some SOAP server impls require even empty SOAPAction headers
	NSDictionary *reqHeaders = [NSDictionary dictionaryWithObject:@"SFCardFanDbGetAction" forKey:@"SOAPAction"];

	// create SOAP request
    WSMethodInvocationRef soapReq = WSMethodInvocationCreate((CFURLRef)url,
                                                             (CFStringRef)method,
                                                             kWSSOAP2001Protocol);

    // set SOAP params
    WSMethodInvocationSetParameters(soapReq, (CFDictionaryRef)params, (CFArrayRef)paramOrder);

    // set method namespace
    WSMethodInvocationSetProperty(soapReq, kWSSOAPMethodNamespaceURI, (CFStringRef)namespace);

    // Add HTTP headers (with SOAPAction header) -- some SOAP impls require even empty SOAPAction headers
    WSMethodInvocationSetProperty(soapReq, kWSHTTPExtraHeaders, (CFDictionaryRef)reqHeaders);

	// invoke SOAP request
	NSDictionary *result = (NSDictionary *)WSMethodInvocationInvoke(soapReq);
	CFRelease(soapReq);
	if (! result) return nil;

	NSMutableDictionary *	station = [NSMutableDictionary dictionary];
	NSArray *		resultSet = [[[result objectForKey:@"/Result"] objectForKey:@"ResultSet"] objectForKey:@"item"];
	NSEnumerator *	enumerator = [resultSet objectEnumerator];
	NSDictionary *	item;

	// 結果を転記
	while (item = [enumerator nextObject])
	{
		[station setObject:[item objectForKey:@"value"] forKey:[item objectForKey:@"key"]];
	}

	[result release];

	return station;
}


/// SFCard Fan DB Service から駅名を取得する
- (NSDictionary *)getStationNameWithStation:(uint8_t *)station regionCode:(int)region
{
	int		areaCode;

#if 0
	// 古い形式（現在は使われていない）
	areaCode = suica_areacode(region, station[0]);
	if (areaCode < 0) return nil;
#else
	// 新しい形式（リージョンをそのまま地区コードとして使用）
	areaCode = region;
#endif

	return [self getStationNameWithAreaCode:areaCode lineCode:station[0] stationCode:station[1]];
}


@end
