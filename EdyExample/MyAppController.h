/* MyAppController */

#import <Cocoa/Cocoa.h>
#import "PasoriKit/USBNotification.h"
#import "PasoriKit/USBDevicePasori.h"

@interface MyAppController : NSObject
{
    IBOutlet NSTextField			*restView;
    IBOutlet NSTableView			*edyTableView;
    IBOutlet NSTextField			*edyNoTextField;
    IBOutlet NSLevelIndicator		*levelIndicator;
    IBOutlet NSProgressIndicator	*progressIndicator;
	
	USBNotification		*usbNotify;
	USBDevicePasori		*usbPasori;
	
	NSMutableArray		*edyValues;
}
@end
