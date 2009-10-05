#import "PasoriKit/pasori.h"
#import "PasoriKit/felica.h"
#import "PasoriKit/suica.h"
#import "PasoriKit/PasoriRequest.h"

#import "MyAppController.h"
#import "SFCardDB.h"


@implementation MyAppController


- (id)init
{
    self = [super init];
    if (self) {
		suicaValues = [[NSMutableArray array] retain];
    }
    return self;
}


- (void)dealloc
{
	[suicaValues release];
	[usbPasori release];

	// PaSoRi のノーティフィケーション通知を削除
	[usbNotify release];

    [super dealloc];
}


#pragma mark -


/// バイナリを１６進数文字列に変換する
- (NSString *)bin2hex:(uint8_t *)data length:(int)len
{
	NSMutableString *	str = [NSMutableString stringWithString:@"0x"];
	int		i;
	
	for (i = 0; i < len; i++)
	{
		[str appendFormat:@"%02X", data[i]];
	}
	
	return str;
}


/// Suica処理の説明文を取得
- (NSString *)suicaDescription:(int)proc
{
	NSString *	note = nil;
	
	switch (proc)
	{
		case 1:
			// 運賃支払(改札出場)
			break;
			
		case 2:
			note = @"チャージ";
			break;
			
		case 3:
			note = @"券購(磁気券購入)";
			break;
			
		case 4:
			note = @"精算";
			break;
			
		case 5:
			note = @"精算 (入場精算)";
			break;
			
		case 6:
			note = @"窓出 (改札窓口処理)";
			break;
			
		case 7:
			note = @"新規 (新規発行)";
			break;
			
		case 8:
			note = @"控除 (窓口控除)";
			break;
			
		case 13:
			note = @"バス (PiTaPa系)";
			break;
			
		case 15:
			note = @"バス (IruCa系)";
			break;
			
		case 17:
			note = @"再発 (再発行処理)";
			break;
			
		case 19:
			note = @"支払 (新幹線利用)";
			break;
			
		case 20:
			note = @"入A (入場時オートチャージ)";
			break;
			
		case 21:
			note = @"出A (出場時オートチャージ)";
			break;
			
		case 31:
			note = @"入金 (バスチャージ)";
			break;
			
		case 35:
			note = @"券購 (バス路面電車企画券購入)";
			break;
			
		case 70:
			note = @"物販";
			break;
			
		case 72:
			note = @"特典 (特典チャージ)";
			break;
			
		case 73:
			note = @"入金 (レジ入金)";
			break;
			
		case 74:
			note = @"物販取消";
			break;
			
		case 75:
			note = @"入物 (入場物販)";
			break;
			
		case 198:
			note = @"物現 (現金併用物販)";
			break;
			
		case 203:
			note = @"入物 (入場現金併用物販)";
			break;
			
		case 132:
			note = @"精算 (他社精算)";
			break;
			
		case 133:
			note = @"精算 (他社入場精算)";
			break;
			
		default:
			note = @"不明";
			break;
	}
	
	return note;
}


/// Suica 利用履歴のアップデート
- (void)updateSuicaValue:(uint8_t *)binary index:(uint8_t)index
{
	suica_value_t *			value = (suica_value_t *)binary;
	NSMutableDictionary *	suicaValue = [NSMutableDictionary dictionary];
	
	[suicaValue setObject:[NSData dataWithBytes:value length:sizeof(suica_value_t)] forKey:@"data"];
	
	// 利用年月日
	NSCalendarDate *	date = [NSCalendarDate dateWithYear:2000+suica_year(value) month:suica_month(value) day:suica_day(value) hour:0 minute:0 second:0 timeZone:nil];
	[suicaValue setObject:date forKey:@"date"];
	
	// 残額
	[suicaValue setObject:[NSNumber numberWithUnsignedShort:suica_balacne(value)] forKey:@"balacne"];
	if (index == 0)
	{	// 先頭の残額を残高として表示
		[balacneView setIntValue:suica_balacne(value)];
	}

	switch (value->proc)
	{
		case 1:
			// 運賃支払(改札出場)
			[suicaValue setObject:[self bin2hex:value->in_station length:sizeof(value->in_station)] forKey:@"in_station"];
			[suicaValue setObject:[self bin2hex:value->out_station length:sizeof(value->out_station)] forKey:@"out_station"];
			break;
	}
	
	// 備考
	NSString *	note = [self suicaDescription:value->proc];
	
	if (note)
	{
		[suicaValue setObject:note forKey:@"note"];
	}
	
	// データの更新
	[suicaValues addObject:suicaValue];
	[suicaTableView noteNumberOfRowsChanged];
}


/// Suicaデータをクリアする
- (void)suicaValueClean
{
	[balacneView setStringValue:@""];

	[suicaValues removeAllObjects];
	[suicaTableView reloadData];
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
			[pasori felicaPolling:FELICA_POLLING_SUICA];
			handled = YES;
			break;

		case PASORI_STATE_POLLING_DONE:
			// ポーリング成功
			// 接続インディケータを変更
			[levelIndicator setIntValue:3];
			// プログレスインディケータを開始
			[progressIndicator startAnimation:self];

			// Suicaの表示データをクリア
			[self suicaValueClean];
			// Suicaの履歴を読出す
			[pasori felicaReadWithoutEncryption02:FELICA_SC_SUICA_VALUE];
			handled = YES;
			break;

		case PASORI_STATE_READING_DONE:
			// データの読出し終了
			if ([lookupSFCardFanDbCheckbox state] == 1)
			{	// 「IC SFCard Fan DB Service参照」チェックボックスが ON の場合
				// SFCard Fan DB Service から駅名を取得する
				[self lookupSFCardFanDb];
			}
			// プログレスインディケータを終了
			[progressIndicator stopAnimation:self];
			break;
			
		case PASORI_STATE_UNTOUCHED:
			// カードがアンタッチされた
			// 接続インディケータを変更
			[levelIndicator setIntValue:2];
			// 再度ポーリングを行う
			[pasori felicaPolling:FELICA_POLLING_SUICA];
			// 実行中だったかもしれないのでプログレスインディケータを終了しておく
			[progressIndicator stopAnimation:self];
			handled = YES;
			break;
	}

	return handled;
}


/// ⑤ Felicaデータの受信
- (BOOL)felicaReceive:(USBDevicePasori *)pasori data:(felica_ans_t *)ans numBytesRead:(uint32_t)numBytesRead
{
	BOOL	handled = NO;

	switch (ans->as.normal.cmd)
	{
		case FELICA_ANS_READ_WITHOUT_ENCRYPTION:
			{
				PasoriRequest *	currRequest = [pasori currRequest];
//				int		serviceCode = [[[currRequest param] objectForKey:@"serviceCode"] unsignedShortValue];
				int		index = [[[currRequest param] objectForKey:@"address"] unsignedShortValue];

				// Suica 利用履歴のアップデート
				[self updateSuicaValue:ans->as.read_wo_enc02.data index:index];
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

	for (i = 0; i < numBytesRead; i++)
	{
		printf("0x%02x, ", buffer[i]);
	}

	printf("(len = %d)\n", numBytesRead);

	return YES;
}


#pragma mark -


/// サービスコードリストの要求
- (IBAction)requestServiceCode:(id)sender
{
	[usbPasori felicaRequestServiceCode];
}


/// システムコードリストの要求
- (IBAction)requestSystemCode:(id)sender
{
	[usbPasori felicaRequestSystemCode];
}


/// 「IC SFCard Fan DB Service参照」チェックボックスが変更されたときの処理
- (IBAction)toggleLookupSFCard:(id)sender
{
	if ([lookupSFCardFanDbCheckbox state] == 1)
	{
		// プログレスインディケータを開始
		[progressIndicator startAnimation:self];
		// SFCard Fan DB Service から駅名を取得する
		[self lookupSFCardFanDb];
		// プログレスインディケータを終了
		[progressIndicator stopAnimation:self];
	}
}


/// SFCard Fan DB Service から駅名を取得する
- (void)lookupSFCardFanDb
{
	int		i;
	
	for (i = 0; i < [suicaValues count]; i++)
	{
		NSMutableDictionary *	suicaValue = [suicaValues objectAtIndex:i];
		NSData *		data = [suicaValue objectForKey:@"data"];
		suica_value_t *	value = (suica_value_t *)[data bytes];
		
		SFCardDB *	sfCardDB = [SFCardDB sharedSFCardDB];

		if ([[suicaValue objectForKey:@"in_station"] hasPrefix:@"0x"])
		{	// 入場駅がコード表記のまま
			NSDictionary *	station1;
			
			station1 = [sfCardDB getStationNameWithStation:value->in_station regionCode:value->region];
			NSString *	name1 = [station1 objectForKey:@"StationName"];
			if (! [name1 isEqual:[NSNull null]]) [suicaValue setObject:name1 forKey:@"in_station"];
		}
		
		if ([[suicaValue objectForKey:@"out_station"] hasPrefix:@"0x"])
		{	// 出場駅がコード表記のまま
			NSDictionary *	station2;
			
			station2 = [sfCardDB getStationNameWithStation:value->out_station regionCode:value->region];
			NSString *	name2 = [station2 objectForKey:@"StationName"];
			if (! [name2 isEqual:[NSNull null]]) [suicaValue setObject:name2 forKey:@"out_station"];
		}

		// 取得に時間がかかるので逐次表示を更新する
		[suicaTableView display];
	}
	
//	[suicaTableView setNeedsDisplay:YES];
}


#pragma mark -


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [suicaValues count];
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[suicaValues objectAtIndex:row] objectForKey:[tableColumn identifier]];
}



@end
