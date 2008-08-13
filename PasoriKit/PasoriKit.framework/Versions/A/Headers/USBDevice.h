//
//  USBDevice.h
//  PaSoRi
//
//  Created by GNUE(鵺) on 07/05/05.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/IOKitLib.h>
#include <IOKit/usb/IOUSBLib.h>


@interface USBDevice : NSObject {
    IBOutlet id		delegate;					///< デリゲータ

    io_service_t	usbService;					///< USB のIOサービス

	IOUSBDeviceInterface **		dev;			///< USB のデバイス・インタフェース
	IOUSBInterfaceInterface	**	intf;			///< USB のインタフェース・インタフェース
	CFRunLoopSourceRef			runLoopSource;	///< ランループソース

	BOOL			deviceOpened;				///< デバイスをオープン中
	NSTimer *		timeoutTimer;				///< タイムアウト検出用のタイマー
}

+ (id)usbDeviceWithService:(io_service_t)service delegate:(id)obj;
- (id)initWithService:(io_service_t)service delegate:(id)obj;

- (io_service_t)getUsbService;
- (NSString *)getDeviceName;
- (UInt32)getLocationID;
- (UInt16)getVendorID;
- (UInt16)getProductID;
- (IOReturn)queryDeviceInterface;
- (IOReturn)deviceOpen;
- (IOReturn)deviceClose;
- (IOReturn)configureDevice;
- (IOReturn)addInterfaceAsyncEventSource;
- (void)removeInterfaceAsyncEventSource;
- (IOReturn)interfaceOpen;
- (IOReturn)interfaceClose;
- (int)findPipeRef:(UInt8)findDirection transferType:(UInt8)findTransferType;

- (IOReturn)sendControl:(UInt16)addr data:(void *)data length:(UInt16)len;
- (void)readPipeCompletetion:(IOReturn)result numBytesRead:(UInt32)numBytesRead;
- (IOReturn)readPipeAsync:(UInt8)pipeRef buffer:(void *)buffer length:(UInt32)len;
- (IOReturn)readPipeAsync:(UInt8)pipeRef buffer:(void *)buffer length:(UInt32)len timeout:(NSTimeInterval)ti;
- (IOReturn)readPipe:(UInt8)pipeRef buffer:(void *)buffer length:(UInt32 *)lenp;
- (IOReturn)readPipe:(UInt8)pipeRef buffer:(void *)buffer length:(UInt32 *)lenp timeout:(NSTimeInterval)ti;

- (IOReturn)open;
- (IOReturn)close;

- (void)timeoutTimerClear;


@end


@interface NSObject(USBDeviceController)

- (BOOL)usbReceiveData:(UInt8 *)buffer numBytesRead:(UInt32)numBytesRead;

@end
