//
//  USBNotification.h
//  PaSoRi
//
//  Created by GNUE(鵺) on 07/05/05.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/IOKitLib.h>
#import "USBDevice.h"


@interface USBNotification : NSObject {
    IBOutlet id delegate;

	IONotificationPortRef	notifyPort;		///< ノーティフィケーションポート
	io_iterator_t			addedIter;		///< 登録通知用イテレータ
	io_iterator_t			removedIter;	///< 削除通知用イテレータ

	Class					usbDeviceClass;	///< インスタンスを生成する USBデバイスのクラス
	NSMutableArray *		deviceList;		///< 使用中のデバイス・リスト
}

+ (id)usbNotificationWithClass:(Class)deviceClass delegate:(id)obj vendor:(long)vendor product:(long)product;
- (id)initWithClass:(Class)deviceClass delegate:(id)obj vendor:(long)vendor product:(long)product;

- (int)regWithVendor:(long)vendor product:(long)product;
- (void)addDevice:(io_service_t)usbDevice;
- (void)removeDevice:(io_service_t)usbDevice;

@end


@protocol USBNotificationController

- (BOOL)usbAddDevice:(USBDevice *)usbDevice;
- (void)usbRemoveDevice:(USBDevice *)usbDevice;

@end
