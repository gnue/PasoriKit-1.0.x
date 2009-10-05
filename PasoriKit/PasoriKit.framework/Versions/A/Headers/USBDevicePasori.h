//
//  USBDevicePasori.h
//  PaSoRi
//
//  Created by GNUE(鵺) on 07/05/06.
//  Copyright 2007 Makoto Nukui. All rights reserved.
//

#import "USBDevice.h"
#import "pasori.h"
#import "felica.h"



/// PaSoRi の状態
typedef enum {
	PASORI_STATE_DISCONNECTED	= 0,			///< 未接続
	PASORI_STATE_INIT0,							///< 初期化０
	PASORI_STATE_INIT1,							///< 初期化１
	PASORI_STATE_INIT2,							///< 初期化２
	PASORI_STATE_INIT3,							///< 初期化３
	PASORI_STATE_INIT4,							///< 初期化４
	PASORI_STATE_INIT5,							///< 初期化５
	PASORI_STATE_READ2,							///< 初期化の最後に送るコマンド（READ2？）
	PASORI_STATE_INITED,						///< 初期化完了
	PASORI_STATE_UNTOUCHED,						///< アンタッチされた
	PASORI_STATE_POLLING,						///< ポーリング中
	PASORI_STATE_POLLING_DONE,					///< ポーリング完了
	PASORI_STATE_CONNECTED,						///< 接続完了
	PASORI_STATE_READING,						///< データの読込み中
	PASORI_STATE_READING_DONE,					///< データの読込み完了
	PASORI_STATE_REQUEST_SERVICE_CODE,			///< サービスコードのリクエスト中
	PASORI_STATE_REQUEST_SYSTEM_CODE,			///< システムコードのリクエスト中
	PASORI_STATE_IDLE,							///< アイドリング中
} pasori_state_t;


@class PasoriRequest;


@interface USBDevicePasori : USBDevice {
	pasori_state_t	currState;					///< 現在の状態

	int			inPipeRef;						///< 入力用パイプ
	uint8_t		buffer[PASORI_MAX_PACKET_LEN];	///< バッファ

	uint8_t		IDm[FELICA_IDM_LEN];			///< 製造ＩＤ
	uint8_t		PMm[FELICA_PMM_LEN];			///< 製造パラメータ
	felica_polling_t	polling;				///< ポーリング情報

	NSTimeInterval		_pollingInterval;		///< ポーリング間隔
	NSTimeInterval		_idlingInterval;		///< アイドリング中のポーリング間隔
	PasoriRequest *		_currRequest;			///< 現在のリクエスト
	NSMutableArray *	_requestQueue;			///< リクエスト・キュー
	NSTimer *	_timer;							///< タイマー
	BOOL		_receiveWaiting;				///< 受信待ちを行うか？
}


+ (id)usbDevicePasoriWithService:(io_service_t)service delegate:(id)obj;
+ (NSArray *)systemCodeArrayFromData:(uint8_t *)data;

- (void)setPollingInterval:(NSTimeInterval)timeInterval;
- (void)setIdlingInterval:(NSTimeInterval)timeInterval;
- (void)setState:(pasori_state_t)state;

- (IOReturn)pasoriSend:(void *)data length:(uint16_t)len;
- (IOReturn)pasoriSendAsync:(void *)data length:(uint16_t)len;
- (IOReturn)pasoriSendACK;
- (IOReturn)pasoriInit;
- (IOReturn)pasoriInitAsync;
- (IOReturn)doAction:(pasori_state_t)state;

- (id)felicaPolling:(uint16_t)systemCode;
- (id)felicaRequestSystemCode;
- (id)felicaRequestServiceCode;
- (id)felicaReadWithoutEncryption02:(uint16_t)serviceCode;

- (id)pasoriRequest:(SEL)selector;
- (id)pasoriRequest:(SEL)selector withObject:(id)obj;
- (void)requestDone;
- (PasoriRequest *)currRequest;

- (uint8_t *)IDm;
- (uint8_t *)PMm;
- (uint16_t)pollingCode;
- (pasori_state_t)currState;

@end


@interface NSObject(USBDevicePasoriController)

- (BOOL)usbReceive:(USBDevicePasori *)pasori data:(uint8_t *)buffer numBytesRead:(uint32_t)numBytesRead;
- (BOOL)felicaReceive:(USBDevicePasori *)pasori data:(felica_ans_t *)ans numBytesRead:(uint32_t)numBytesRead;
- (BOOL)pasoriEvent:(USBDevicePasori *)pasori state:(pasori_state_t)state;

@end
