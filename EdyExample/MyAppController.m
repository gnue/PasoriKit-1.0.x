#import "PasoriKit/pasori.h"
#import "PasoriKit/felica.h"
#import "PasoriKit/edy.h"
#import "PasoriKit/PasoriRequest.h"

#import "MyAppController.h"


@implementation MyAppController


- (id)init
{
    self = [super init];
    if (self) {
		edyValues = [[NSMutableArray array] retain];
    }
    return self;
}


- (void)dealloc
{
	[edyValues release];

	[usbPasori release];
	// PaSoRi のノーティフィケーション通知を削除
	[usbNotify release];

    [super dealloc];
}


#pragma mark -



/// Edy番号のアップデート
- (void)updateEdyNo:(uint8_t *)binary index:(uint8_t)index
{
	if (index == 0)
	{
		edy_info0_t *	info = (edy_info0_t *)binary;
		
		NSString *	edyNo = [NSString stringWithFormat:@"%02x%02x-%02x%02x-%02x%02x-%02x%02x",
							 info->edyno[0], info->edyno[1],
							 info->edyno[2], info->edyno[3],
							 info->edyno[4], info->edyno[5],
							 info->edyno[6], info->edyno[7]];
		
		[edyNoTextField setStringValue:edyNo];
	}
}


/// Edy利用履歴のアップデート
- (void)updateEdyValue:(uint8_t *)binary index:(uint8_t)index
{
	edy_value_t *	value = (edy_value_t *)binary;
	NSMutableDictionary *	edyValue = [NSMutableDictionary dictionary];

	// 利用年月日
	struct tm	tm;
	time_t		t;
	int			days;
		
	days = edy_days(value);
	
	memset(&tm, 0, sizeof(tm));
	tm.tm_year = 2000 - 1900;
	tm.tm_mday = 1;
	t = mktime(&tm);
	
	t += days * 24 * 60 * 60;
	t += edy_sec(value);
	
	[edyValue setObject:[NSDate dateWithTimeIntervalSince1970:t] forKey:@"date"];

	// 入出金
	switch (value->type)
	{
		case 0x02:	// 入金（チャージ）
		case 0x04:	// 入金（Edyギフト）
			[edyValue setObject:[NSNumber numberWithUnsignedShort:edy_use(value)] forKey:@"charge"];
			break;
			
		case 0x20:
			// 出金
			[edyValue setObject:[NSNumber numberWithUnsignedShort:edy_use(value)] forKey:@"use"];
			break;
	}

	// 残額
	[edyValue setObject:[NSNumber numberWithUnsignedShort:edy_rest(value)] forKey:@"rest"];
	if (index == 0)
	{
		[restView setIntValue:edy_rest(value)];
	}

	// 備考
	switch (value->type)
	{
		case 0x04:	// 入金（Edyギフト）
			[edyValue setObject:@"Edyギフト" forKey:@"note"];
			break;
	}

	// データの更新
	[edyValues addObject:edyValue];
	[edyTableView noteNumberOfRowsChanged];
}


/// Edyデータをクリアする
- (void)edyValueClean
{
	[edyNoTextField setStringValue:@""];
	[restView setStringValue:@""];
	
	[edyValues removeAllObjects];
	[edyTableView reloadData];
}


#pragma mark -


// アプリケーション起動完了通知
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// ① PaSoRi のノーティフィケーション通知を登録
	usbNotify = [[USBNotification usbNotificationWithClass:[USBDevicePasori class]
												  delegate:self
													vendor:PASORI_USB_VENDOR
												   product:PASORI_USB_PRODUCT] retain];
}


/// ② USBコネクタにデバイスが挿入された
- (BOOL)usbAddDevice:(USBDevice *)usbDevice
{
	if (usbPasori)
	{	// 既に使っているので新しく挿入されたデバイスは使わない
		return NO;
	}

	// あとで使う場合はインスタンス変数に登録しておく
	usbPasori = (USBDevicePasori *)[usbDevice retain];

	// 接続インディケータを変更
	[levelIndicator setIntValue:1];

	// このデバイスは使うので YES を返す
	return YES;
}


/// ③ USBコネクタからデバイスが抜かれた
- (void)usbRemoveDevice:(USBDevice *)usbDevice
{
	if ([usbDevice isEqual:usbPasori])
	{	// 使っているデバイスならば後始末をする
		[usbPasori release];
		usbPasori = nil;
		// 接続インディケータを変更
		[levelIndicator setIntValue:0];
	}
}


/// ④ PaSoRiからのイベント通知
- (BOOL)pasoriEvent:(USBDevicePasori *)pasori state:(pasori_state_t)state
{
	BOOL	handled = NO;

	switch (state)
	{
		case PASORI_STATE_INITED:
			// PaSoRiの初期化完了
			// 接続インディケータを変更
			[levelIndicator setIntValue:2];
			// ポーリングを行う
			[pasori felicaPolling:FELICA_POLLING_EDY];
			handled = YES;
			break;

		case PASORI_STATE_POLLING_DONE:
			// ポーリング成功
			// 接続インディケータを変更
			[levelIndicator setIntValue:3];
			// プログレスインディケータを開始
			[progressIndicator startAnimation:self];

			// Edyの表示データをクリア
			[self edyValueClean];
			// Edy番号を読出す
			[pasori felicaReadWithoutEncryption02:FELICA_SC_EDY_INFO];
			// Edyの履歴を読出す
			[pasori felicaReadWithoutEncryption02:FELICA_SC_EDY_VALUE];
			handled = YES;
			break;

		case PASORI_STATE_READING_DONE:
			// データの読出し終了
			// プログレスインディケータを終了
			[progressIndicator stopAnimation:self];
			break;
			
		case PASORI_STATE_UNTOUCHED:
			// カードがアンタッチされた
			// 接続インディケータを変更
			[levelIndicator setIntValue:2];
			// 再度ポーリングを行う
			[pasori felicaPolling:FELICA_POLLING_EDY];
			// 実行中だったかもしれないのでプログレスインディケータを終了しておく
			[progressIndicator stopAnimation:self];
			handled = YES;
			break;
	}

	return handled;
}


/// ⑤ Felicaデータの受信
- (BOOL)felicaReceive:(USBDevicePasori *)pasori data:(felica_ans_t *)ans numBytesRead:(UInt32)numBytesRead
{
	BOOL	handled = NO;

	switch (ans->as.normal.cmd)
	{
		case FELICA_ANS_READ_WITHOUT_ENCRYPTION:
			{
				PasoriRequest *	currRequest = [pasori currRequest];
				int		serviceCode = [[[currRequest param] objectForKey:@"serviceCode"] unsignedShortValue];
				int		index = [[[currRequest param] objectForKey:@"address"] unsignedShortValue];

				switch (serviceCode)
				{
					case FELICA_SC_EDY_INFO:
						// Edy 番号のアップデート
						[self updateEdyNo:ans->as.read_wo_enc02.data index:index];
						break;

					case FELICA_SC_EDY_VALUE:
						// Edy 利用履歴のアップデート
						[self updateEdyValue:ans->as.read_wo_enc02.data index:index];
						break;
				}
			}
			handled = YES;
			break;
	}

	return handled;
}


/// ⑥ USBデータの受信
- (BOOL)usbReceive:(USBDevicePasori *)pasori data:(uint8_t *)buffer numBytesRead:(uint32_t)numBytesRead
{
	int		i;

	printf("STATE = %2d: ", [pasori currState]);

	for (i = 0; i < numBytesRead; i++)
	{
		printf("0x%02x, ", buffer[i]);
	}

	printf("(len = %d)\n", numBytesRead);

	return YES;
}


#pragma mark -


- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [edyValues count];
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	return [[edyValues objectAtIndex:row] objectForKey:[tableColumn identifier]];
}



@end
