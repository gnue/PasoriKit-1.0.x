/*------------------------------------------------------------------------*/
/**
 * @file	felica.h
 * @brief   Felica
 *
 * @author  M.Nukui
 * @date	2007-04-30
 *
 * Copyright (C) 2007 M.Nukui All rights reserved.
 */


#ifndef	FELICA_H
#define	FELICA_H


#include <stdlib.h>


#define FELICA_POLLING_ANY						0xFFFF		///< すべて

#define FELICA_CMD_POLLING						0			///< ポーリング（コマンド）
#define FELICA_ANS_POLLING						1			///< ポーリング（応答）
//#define FELICA_CMD_REQUEST_SERVICE			2			///< サービスコードの要求（コマンド）
//#define FELICA_ANS_REQUEST_SERVICE			3			///< サービスコードの要求（応答）
#define FELICA_CMD_REQUEST_RESPONSE				4			///< レスポンスの要求（コマンド）
#define FELICA_ANS_REQUEST_RESPONSE				5			///< サービスコードの要求（応答）
#define FELICA_CMD_READ_WITHOUT_ENCRYPTION		6			///< 暗号なしの読出し（コマンド）
#define FELICA_ANS_READ_WITHOUT_ENCRYPTION		7			///< 暗号なしの読出し（応答）
#define FELICA_CMD_WRITE_WITHOUT_ENCRYPTION		8			///< 暗号なしの書込み（コマンド）
#define FELICA_ANS_WRITE_WITHOUT_ENCRYPTION		9			///< 暗号なしの書込み（応答）
#define FELICA_CMD_REQUEST_SERVICE_CODE			0x0A		///< サービスコードリストの要求（コマンド）
#define FELICA_ANS_REQUEST_SERVICE_CODE			0x0B		///< サービスコードリストの要求（応答）
#define FELICA_CMD_REQUEST_SYSTEM_CODE			0x0C		///< システムコードリストの要求（コマンド）
#define FELICA_ANS_REQUEST_SYSTEM_CODE			0x0D		///< システムコードリストの要求（応答）
#define FELICA_CMD_PUSH							0xB0		///< FeliCaツールバー : メッセージ送信（コマンド）

#define FELICA_IDM_LEN							8			///< IDm の長さ
#define FELICA_PMM_LEN							8			///< PMm の長さ

#define FELICA_CMD_POLLING_LEN					5			///< ポーリングのコマンド長
#define FELICA_CMD_REQUEST_SERVICE_CODE_LEN		11			///< サービスコードリスト要求のコマンド長
#define FELICA_CMD_REQUEST_SYSTEM_CODE_LEN		9			///< システムコードリスト要求のコマンド長
#define FELICA_CMD_READ_WITHOUT_ENCRYPTION_LEN	15			///< 暗号無し読出しのコマンド長


/** IDm : Manufacture ID Block（製造ＩＤ）
 *
 *	@note	リトルエンディアン
 */
typedef struct {
	uint16_t	code;		///< 製造者コード
	uint16_t	machine;	///< 製造器
	int16_t		date;		///< 日付（1970年からの経過日時）
	uint16_t	sn;			///< シリアル
} felica_IDm_t;


/** PMm : Manufacture Parameter Block（製造パラメータ）
 *
 *	@note	リトルエンディアン
 */
typedef struct {
	uint16_t	card_version;			///< カードバージョン
	uint8_t		response_time_info[6];	///< コマンド処理時間に関するデータ
} felica_PMm_t;


/// Felica カード情報
typedef struct {
	felica_IDm_t	IDm;		///< IDm（製造ＩＤ）
	felica_PMm_t	PMm;		///< PMm（製造パラメータ）
} felica_t;


/// Polling 情報
typedef struct {
	uint16_t	system_code;	///< システムコード
	uint8_t		rfu;			///< RFU
	uint8_t		time_slot;		///< タイムスロット
} felica_polling_t;



#endif /* FELICA_H */
