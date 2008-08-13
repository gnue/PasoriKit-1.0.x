/*------------------------------------------------------------------------*/
/**
 * @file	pasori.h
 * @brief   PaSoRi
 *
 * @author  M.Nukui
 * @date	2007-04-30
 *
 * Copyright (C) 2007 M.Nukui All rights reserved.
 */


#include <stdlib.h>
#include <stdbool.h>
#include "felica.h"


#ifndef	PASORI_H
#define	PASORI_H


#define PASORI_USB_VENDOR						0x054C		///< PaSoRiのベンダーＩＤ
#define PASORI_USB_PRODUCT						0x01BB		///< PaSoRiのプロダクツＩＤ

#define PASORI2_CMD_SELF_DIAGNOSIS				0x52		///< 自己診断（コマンド）
#define PASORI2_ANS_SELF_DIAGNOSIS				0x53		///< 自己診断（応答）
#define PASORI2_CMD_READ1						0x54		///< PaSoRi読み取り時初期化（コマンド） - リセット？
#define PASORI2_ANS_READ1						0x55		///< PaSoRi読み取り時初期化（応答）
#define PASORI2_CMD_GET_FIRMWARE_VERSION		0x58		///< ファームウェアバージョンの取得？（コマンド）
#define PASORI2_ANS_GET_FIRMWARE_VERSION		0x59		///< ファームウェアバージョンの取得？（応答）
#define PASORI2_CMD_READ2						0x5A		///< PaSoRi読み取り時初期化（コマンド）
#define PASORI2_ANS_READ2						0x5B		///< PaSoRi読み取り時初期化（応答）
#define PASORI2_CMD_SEND_PACKET					0x5c		///< FeliCaプロトコルパススルー（コマンド）
#define PASORI2_ANS_SEND_PACKET					0x5d		///< FeliCaプロトコルパススルー（応答）
#define PASORI2_DIAG_COMMUNICATION_LINE_TEST	0x00
#define PASORI2_DIAG_EEPROM_TEST				0x01
#define PASORI2_DIAG_RAM_TEST					0x02
#define PASORI2_DIAG_CPU_FUNCTION_TEST			0x03
#define PASORI2_DIAG_CPU_FANCTION_TEST			0x03
#define PASORI2_DIAG_POLLING_TEST_TO_CARD		0x10


#define PASORI_ERR_PACKET_INVALID				-2			///< パケットが不正

#define PASORI_NACK								-1			///< 否定応答
#define PASORI_ACK								0			///< 確認応答

#define PASORI_MAX_DATA_LEN						254							///< データの最大長
#define PASORI_MAX_PACKET_LEN					(7 + PASORI_MAX_DATA_LEN)	///< パケットの最大長


/// FeliCaの応答データ（一般形）
typedef struct {
	uint8_t	cmd;					///< コマンド
	uint8_t	IDm[FELICA_IDM_LEN];	///< 製造ＩＤ
	uint8_t	data[0];				///< データ
} felica_ans_normal_t;


/// FeliCaの応答データ（ポーリング）
typedef struct {
	uint8_t	cmd;					///< コマンド
	uint8_t	IDm[FELICA_IDM_LEN];	///< 製造ＩＤ
	uint8_t	PMm[FELICA_PMM_LEN];	///< 製造パラメータ
} felica_ans_polling_t;


/// FeliCaの応答データ（暗号なしの読出し）
typedef struct {
	uint8_t	cmd;					///< コマンド
	uint8_t	IDm[FELICA_IDM_LEN];	///< 製造ＩＤ
	uint8_t	err[2];					///< エラーコード
	uint8_t	unkown[1];				///< 不明
	uint8_t	data[0];				///< 受信データ
} felica_ans_read_wo_enc02_t;


/// FeliCaの応答データ
typedef struct {
	union {
		felica_ans_normal_t			normal;			///< 一般形
		felica_ans_polling_t		polling;		///< ポーリング
		felica_ans_read_wo_enc02_t	read_wo_enc02;	///< 暗号なしの読出し
	} as;
} felica_ans_t;


#ifdef __cplusplus
extern "C" {
#endif


size_t	pasori_packet_size(size_t len);
int		pasori_packet_assemble(uint8_t packet[], const uint8_t data[], size_t len);
int		pasori_packet_disassemble(uint8_t packet[], size_t size, uint8_t ** data);

size_t	felica_packet_size(size_t len);
int		felica_packet_assemble(uint8_t packet[], const uint8_t data[], size_t len);
int		felica_packet_disassemble(uint8_t packet[], size_t size, felica_ans_t ** data);

int		felica_cmd_polling(uint8_t cmd[], uint16_t systemcode, uint8_t rfu, uint8_t timeslot);
int		felica_cmd_request_service_code(uint8_t cmd[], uint8_t IDm[], uint16_t index);
int		felica_cmd_request_system_code(uint8_t cmd[], uint8_t IDm[]);
int		felica_cmd_read_wo_enc02(uint8_t cmd[], uint8_t IDm[], uint16_t servicecode, uint8_t mode, uint8_t addr);


#ifdef __cplusplus
}
#endif



#endif /* PASORI_H */
