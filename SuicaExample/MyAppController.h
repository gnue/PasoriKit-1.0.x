/* MyAppController */

#import <Cocoa/Cocoa.h>
#import "PasoriKit/USBNotification.h"
#import "PasoriKit/USBDevicePasori.h"

@interface MyAppController : NSObject
{
	IBOutlet NSTextField			*balacneView;
    IBOutlet NSTableView			*suicaTableView;
    IBOutlet NSButton				*lookupSFCardFanDbCheckbox;
    IBOutlet NSLevelIndicator		*levelIndicator;
    IBOutlet NSProgressIndicator	*progressIndicator;
	
	USBNotification		*usbNotify;
	USBDevicePasori		*usbPasori;
	
	NSMutableArray		*suicaValues;
}
- (IBAction)toggleLookupSFCard:(id)sender;
- (void)lookupSFCardFanDb;
@end
