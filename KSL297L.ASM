;;##############################################################################
;;File description
;;This file includes the subroutines about RF config and setting
;;Date:2013/12/10
;;##############################################################################
;;/********************SPI  REGISTER  ********************/
#define	R_REGISTER				000H                            				;;SPI read RF data
#define	W_REGISTER				020H                            				;;SPI write RF data
#define	R_RX_PAYLOAD			061H                            				;;Read RX Payload
#define	W_TX_PAYLOAD			0A0H                            				;;Write TX Payload
#define	FLUSH_TX				0E1H                            				;;Flush RX FIFO
#define	FLUSH_RX				0E2H                            				;;Flush TX FIFO
#define	REUSE_TX_PL				0E3H                            				;;Reuse TX Payload
#define	ACTIVATE				050H                            				;;ACTIVATE
#define	DEACTIVATE				050H                            				;;DEACTIVATE
#define	R_RX_PL_WID				060H                            				;;Read width of RX data
#define	W_ACK_PAYLOAD			0A8H                            				;;Data with ACK
#define	W_TX_PAYLOAD_NOACK		0B0H                            				;;TX Payload no ACK Request
#define	CE_FSPI_ON	        	0FDH                            				;; CE HIGH
#define	CE_FSPI_OFF	        	0FCH                            				;; CE LOW
#define	RST_FSPI	        	053H                            				;; RESET
#define	NOP_N					0FFH
;;/******************CONTROL  REGISTER*******************/
#define	CONFIG              	000H
#define	EN_AA					001H
#define	EN_RXADDR				002H
#define	SETUP_AW				003H
#define	SETUP_RETR				004H
#define	RF_CH					005H
#define	RF_SETUP				006H
#define	RF_STATUS				007H
#define	OBSERVE_TX				008H
#define	RPD			        	009H
#define	RX_ADDR_P0				00AH
#define	RX_ADDR_P1				00BH
#define	RX_ADDR_P2				00CH
#define	RX_ADDR_P3				00DH
#define	RX_ADDR_P4				00EH
#define	RX_ADDR_P5				00FH
#define	TX_ADDR					010H
#define	RX_PW_P0				011H
#define	RX_PW_P1				012H
#define	RX_PW_P2				013H
#define	RX_PW_P3				014H
#define	RX_PW_P4				015H
#define	RX_PW_P5				016H
#define	FIFO_STATUS				017H
#define	DEM_CAL					019H
#define RF_CAL2					01AH
#define DEM_CAL2				01BH
#define	DYNPD					01CH
#define	FEATURE					01DH
#define	RF_CAL					01EH
#define	BB_CAL					01FH
;;;;;;;;;;;;;;;;;;;;;;;;;;RF parameter;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#define	TRANS_ENHANCE_MODE    	1                                         		;;传输类型增强型
#define	TRANS_BURST_MODE      	2                                         		;;传输类型普通型
       	                                                                		;;
#define	C_RF13dBm               03FH                            				;; 13dBm
#define	C_RF10dBm               00FH                            				;; 10dBm
#define	C_RF8dBm                015H                            				;; 8dbm
#define	C_RF7dBm                007H                            				;; 7dbm
#define	C_RF5dBm                02cH                            				;; 5dbm
#define	C_RF4dBm                006H                            				;; 4dbm
#define	C_RF2dBm                005H                            				;; 2dbm
#define	C_RF0dBm                00BH                            				;; 0dBm
#define	C_RF_3dBm               004H                            				;; -3dBm
#define	C_RF_6dBm               00AH                            				;; -6dBm
#define	C_RF_10dBm              002H                            				;; -10dBm
#define	C_RF_18dBm              001H                            				;; -18dBm
#define	C_RF_30dBm              000H                            				;; -30dBm

#define C_DR_1M                 000H											;;通信速率 1Mbps
#define C_DR_2M                 040H											;;通信速率 2Mbps
#define C_DR_250K               0C0H											;;通信速率 250Kbps

#define	MAX_RT					BIT_4
#define	TX_DS					BIT_5
#define	RX_DR					BIT_6
#define	RF_ERR					BIT_7
#define	RF_STATE_BIT			(BIT_4|BIT_5|BIT_6)

#define	TX_EMPTY				BIT_4
#define	TX_FULL					BIT_5
;;---------------------------------------------------------------
#define	IO_RF_MISO				PORTC, 7
#define	IO_RF_MOSI				PORTC, 6
#define	IO_RF_SCK				PORTC, 4
#define	IO_RF_CSN				PORTC, 5
;;------------------------------------------------
#define	F_RF_TX_OK				R_RF_TX_RESULT, 5
#define	F_RF_RX_OK				R_RF_RX_RESULT, 6
;;------------------------------------------------
#define C_RF_PACKET_SIZE		7
#define ADD_WIDTH				4
#DEFINE	C_CHN_INDEX				4
#define	C_CMD_CHN				4
;==========================================================
RF_CE_HIGH:
		;CLRR		R_SPI_DATA
		;MOVIA		CE_FSPI_ON
		;LJUMP		RF_SPI_ADR_SET
		BSR			PORTC, 3
		RET
RF_CE_LOW:
		;CLRR		R_SPI_DATA
		;MOVIA		CE_FSPI_OFF
		BCR			PORTC, 3
		RET
RF_SPI_ADR_SET:
		MOVAR		R_SPI_ADR
		LCALL 		SPI_WRITE
		RET
;;------------------------------------------------
RF_SET_CMD_CHN:
		MOVIA		C_CMD_CHN
		LJUMP		RF_SET_CHANNEL
RF_SET_NEXT_CHN:
		INCR		R_CHN_INDEX, TO_R
		MOVR		R_CHN_INDEX, TO_A	
		XORIA		C_CHN_INDEX
		BTSC		STATUS, Z_B
		CLRR		R_CHN_INDEX	
		MOVR		R_CHN_INDEX, TO_A
		MOVAR		R_TEMP00
		LCALL		TABLE_RF_CHANNEL
RF_SET_CHANNEL:
		MOVAR		R_SPI_DATA
		MOVIA		(W_REGISTER+RF_CH)
		LCALL		RF_SPI_ADR_SET
		LCALL		DELAY_100US
		RET
;==========================================================
RF_SET_ID_ADR:
		MOVIA		(W_REGISTER + TX_ADDR)
		MOVAR		R_SPI_ADR
		MOVR		R_RF_ADDR0,TO_A
		MOVAR		R_RF_SEND_0
		MOVR		R_RF_ADDR1,TO_A
		MOVAR		R_RF_SEND_1
		MOVR		R_RF_ADDR2,TO_A
		MOVAR		R_RF_SEND_2
		MOVR		R_RF_ADDR3,TO_A
		MOVAR		R_RF_SEND_3
		LCALL		RF_SPI_ADD_SET
		MOVIA		(W_REGISTER + RX_ADDR_P0)
		MOVAR		R_SPI_ADR
		MOVR		R_RF_ADDR0,TO_A
		MOVAR		R_RF_SEND_0
		MOVR		R_RF_ADDR1,TO_A
		MOVAR		R_RF_SEND_1
		MOVR		R_RF_ADDR2,TO_A
		MOVAR		R_RF_SEND_2
		MOVR		R_RF_ADDR3,TO_A
		MOVAR		R_RF_SEND_3
		LJUMP		RF_SPI_ADD_SET
RF_SET_DEFAULT_ADR:
		MOVIA		(W_REGISTER + TX_ADDR)
		MOVAR		R_SPI_ADR
		LCALL		RF_SET_DEFAULT_ADR_NEXT
		MOVIA		(W_REGISTER + RX_ADDR_P0)
		MOVAR		R_SPI_ADR
RF_SET_DEFAULT_ADR_NEXT:
		MOVIA		055H
		MOVAR		R_RF_SEND_0
		MOVAR		R_RF_SEND_1
		MOVAR		R_RF_SEND_2
		MOVAR		R_RF_SEND_3
RF_SPI_ADD_SET:
		MOVIA		ADD_WIDTH
RF_SPI_FIFO_SET:
		MOVAR		R_RF_DATA_LEN
		LCALL		RF_FIFO_RW
		RET
;==========================================================
RF_SET0DB_PWR:
		MOVIA		(C_RF0dBm|C_DR_1M)
		LJUMP		RF_SET_PWR_NEXT
RF_SET8DB_PWR:
		MOVIA		(C_RF8dBm|C_DR_1M)
		LJUMP		RF_SET_PWR_NEXT
;RF_SET_30DB_PWR:
;		MOVIA		(C_RF_30dBm|C_DR_1M)
;		LJUMP		RF_SET_PWR_NEXT
RF_SET_6DB_PWR:
		MOVIA		(C_RF_6dBm|C_DR_1M)
		LJUMP		RF_SET_PWR_NEXT
RF_SET_PWR_NEXT:
		MOVAR		R_SPI_DATA
		MOVIA		(W_REGISTER + RF_SETUP)
		LJUMP		RF_SPI_ADR_SET
;==========================================================
/*RF_SET_DATA_LENTH:
		MOVR		R_RF_LENTH,TO_A
		MOVAR		R_SPI_DATA
		MOVIA		(W_REGISTER + RX_PW_P0)
		LJUMP		RF_SPI_ADR_SET*/
/*RF_GET_RSSI:
		CLRR		R_SPI_DATA
		MOVIA		(R_REGISTER + RPD)
		MOVAR		R_SPI_ADR
		LCALL 		SPI_READ
		MOVR		R_SPI_DATA, TO_A
		ANDIA		0FH
		RET*/
;==========================================================
; RF KSL297L initialize subroutine
;==========================================================
INIT_RF:
		LCALL		RF_CE_LOW
		LCALL		DELAY_30MS
INIT_RF_2:
		LCALL		RF_CE_LOW

		MOVIA		RST_FSPI													;; Reset RF
		MOVAR		R_SPI_ADR
		MOVIA		05AH
		MOVAR		R_SPI_DATA
		LCALL		SPI_WRITE
		LCALL		DELAY_2MS
		MOVIA		RST_FSPI
		MOVAR		R_SPI_ADR
		MOVIA		0A5H
		MOVAR		R_SPI_DATA
		LCALL		SPI_WRITE

		MOVIA		(W_REGISTER + BB_CAL)									;; Set RF Config address
		MOVAR		R_SPI_ADR
		MOVIA		00AH
		MOVAR		R_RF_SEND_0
		MOVIA		06DH
		MOVAR		R_RF_SEND_1
		MOVIA		067H
		MOVAR		R_RF_SEND_2
		MOVIA		09CH
		MOVAR		R_RF_SEND_3
		MOVIA		046H
		MOVAR		R_RF_SEND_4
		MOVIA		5
		LCALL		RF_SPI_FIFO_SET
		MOVIA		(W_REGISTER + RF_CAL)
		MOVAR		R_SPI_ADR
		MOVIA		0F6H
		MOVAR		R_RF_SEND_0
		MOVIA		037H
		MOVAR		R_RF_SEND_1
		MOVIA		05DH
		MOVAR		R_RF_SEND_2
		MOVIA		3
		LCALL		RF_SPI_FIFO_SET
		MOVIA		(W_REGISTER + RF_CAL2)
		MOVAR		R_SPI_ADR
		MOVIA		045H
		MOVAR		R_RF_SEND_0
		MOVIA		021H
		MOVAR		R_RF_SEND_1
		MOVIA		0EFH
		MOVAR		R_RF_SEND_2
		MOVIA		0ACH
		MOVAR		R_RF_SEND_3
		MOVIA		05AH
		MOVAR		R_RF_SEND_4
		MOVIA		050H													;; Disable CE pull down
		MOVAR		R_RF_SEND_5
		MOVIA		6
		MOVAR		R_RF_DATA_LEN
		LCALL		RF_FIFO_RW
		MOVIA		(W_REGISTER + DEM_CAL2)
		MOVAR		R_SPI_ADR
		MOVIA		00BH
		MOVAR		R_RF_SEND_0
		MOVIA		0DFH
		MOVAR		R_RF_SEND_1
		MOVIA		002H
		MOVAR		R_RF_SEND_2
		MOVIA		3
		MOVAR		R_RF_DATA_LEN
		LCALL		RF_FIFO_RW
		CLRR		R_RF_INT_CNT
INIT_RF_LOOP:
		MOVR		R_RF_INT_CNT,TO_A
		MOVAR		R_TEMP00
		LCALL		TABLE_RF_ADR
		MOVAR		R_SPI_ADR
		MOVR		R_RF_INT_CNT,TO_A
		MOVAR		R_TEMP00
		LCALL		TABLE_RF_DATA
		MOVAR		R_SPI_DATA
		LCALL		SPI_WRITE
		INCR		R_RF_INT_CNT,TO_R
		MOVR		R_RF_INT_CNT,TO_A
		XORWI		10
		BTSS		STATUS,Z
		LJUMP		INIT_RF_LOOP
		LCALL 		RF_CLR_FLUSH_RX
		LCALL 		RF_CLR_FLUSH_TX
		LCALL		RF_CLR_STATUS
		LCALL		RF_SET8DB_PWR
		LCALL		SET_TX_MODE
		LCALL		RF_SET_ID_ADR
		LCALL		RF_SET_NEXT_CHN
		RET
;;==========================================================
SET_TX_MODE:
RF_MODULE_WAKE:
		LCALL		RF_CE_LOW
		LCALL		RF_CLR_FLUSH_TX
		LCALL		RF_CLR_FLUSH_RX
		MOVIA		8EH
		MOVAR		R_SPI_DATA
		MOVIA		(W_REGISTER+CONFIG)
		LJUMP		RF_SPI_ADR_SET
;----------------------------------------------------
SET_RX_MODE:
		LCALL		RF_CE_LOW
		LCALL		RF_CLR_FLUSH_RX
		MOVIA		8FH
		MOVAR		R_SPI_DATA
		MOVIA		(W_REGISTER+CONFIG)
		LCALL		RF_SPI_ADR_SET
		LJUMP		RF_CE_HIGH							;CE = 1,
;----------------------------------------------------
RF_MODULE_SLEEP:
		LCALL		RF_CE_LOW
		CLRR		R_SPI_DATA
		MOVIA		CONFIG	+ W_REGISTER
		LJUMP		RF_SPI_ADR_SET
;;==========================================================
RF_CARRIER_TEST:
		LCALL		RF_CE_LOW
		MOVIA		8EH
		MOVAR		R_SPI_DATA
		MOVIA		(W_REGISTER+CONFIG)	
		LCALL		RF_SPI_ADR_SET
		LCALL		RF_SET8DB_PWR
		MOVIA		40
		LCALL		RF_SET_CHANNEL
		MOVIA		0E1H
		MOVAR		R_SPI_DATA
		MOVIA		(W_REGISTER + DEM_CAL)
		LCALL		RF_SPI_ADR_SET
		LCALL		RF_CE_LOW
RF_CARRIER_TEST_LOOP:
		CLRWDT
		MOVIA		0X01
		XORAR		PORTC,TO_R
		LCALL		DELAY_50MS
		LJUMP		RF_CARRIER_TEST_LOOP
RF_EXIT_CARRIER_TEST:
		MOVIA		001H
		MOVAR		R_SPI_DATA
		MOVIA		(W_REGISTER + DEM_CAL)
		LJUMP		RF_SPI_ADR_SET
;---------------------------------------------------------
RF_CLR_FLUSH_TX:
		CLRR		R_SPI_DATA
		MOVIA		FLUSH_TX
		LJUMP		RF_SPI_ADR_SET
RF_CLR_FLUSH_RX:
		CLRR		R_SPI_DATA
		MOVIA		FLUSH_RX
		LJUMP		RF_SPI_ADR_SET
RF_CLR_STATUS:
		MOVIA		070H									
		MOVAR		R_SPI_DATA
		MOVIA		(W_REGISTER + RF_STATUS)
		LJUMP		RF_SPI_ADR_SET
;;=========================================================
;总长8ms左右
SEND_RF_DATA:
		MOVIA		MAX_RT									;; Default state is MAX_RETRY
		MOVAR		R_RF_TX_RESULT
		MOVIA		C_RF_PACKET_SIZE
		MOVAR		R_RF_DATA_LEN
		MOVIA		W_TX_PAYLOAD
		MOVAR		R_SPI_ADR
		LCALL		RF_FIFO_RW
		LCALL		RF_CE_HIGH
;		RMB7		INTCON
		LCALL		DELAY_50US
;		LCALL		DELAY_50US
;		SMB7		INTCON
		LCALL		RF_CE_LOW
;;1M&2M config
;;Waiting for IRQ duration is 1ms~6mS
;;250K config
;;Waiting for IRQ duration is 2ms~6mS
		MOVIA		25										;;
		MOVAR		R_RF_DATA_LEN
SEND_RF_DATA_COMPLETE_DETECT:								;; SPI byte RW timer is about 250uS while Instruction frequency is 3.64/4
		LCALL 		DELAY_50US
		MOVIA		(R_REGISTER + RF_STATUS)      			; Check sending RF packet successful or not. If failed, retry; Max APP_RETRY_TIMES times.
		MOVAR 		R_SPI_ADR
		LCALL		SPI_READ
		MOVR		R_SPI_DATA, TO_A
		MOVAR		R_RF_TX_RESULT
		ANDIA		B'00110000';;(TX_DS+MAX_RT)
		BTRSS		STATUS, Z_B								;; If not complete
		LGOTO		SEND_RF_DATA_COMPLETE
		DECRSZ		R_RF_DATA_LEN, TO_R
		LGOTO		SEND_RF_DATA_COMPLETE_DETECT
		LCALL 		RF_CLR_FLUSH_TX
SEND_RF_DATA_COMPLETE:
		MOVR		R_RF_TX_RESULT, TO_A					;; Check any data in RX FIFO
		ANDIA		0EH
		XORIA		0EH
		BTRSC		STATUS, Z_B
		LGOTO		SEND_RF_CLR_STATUS
		LCALL 		RF_CLR_FLUSH_RX
SEND_RF_CLR_STATUS:
		LCALL		RF_CLR_STATUS
SEND_RF_COMPLETE_HANDLE:
SEND_RF_DATA_QUIT:
		RET
;;=========================================================
REC_RF_DATA:
		MOVIA		(R_REGISTER + RF_STATUS)
		MOVAR		R_SPI_ADR
		LCALL		SPI_READ
		MOVR		R_SPI_DATA, TO_A
		MOVAR		R_RF_RX_RESULT
		ANDIA		RX_DR
		XORIA		RX_DR
		BTRSS		STATUS, Z_B
		LGOTO		RF_REC_FAIL
		LCALL		RF_CE_LOW
		LGOTO		$+1
		LGOTO		$+1
		MOVIA		R_RX_PAYLOAD  					;;写R_RX_PAYLOAD
		MOVAR		R_SPI_ADR
		MOVIA		C_RF_PACKET_SIZE
		MOVAR		R_RF_DATA_LEN
		LCALL		RF_FIFO_RW
		LCALL 		RF_CLR_FLUSH_RX
		LCALL 		RF_CLR_FLUSH_TX
		LCALL		RF_CLR_STATUS
		LCALL		RF_CE_HIGH
RF_REC_FAIL:
		RET
;;=========================================================
;input:R_SPI_ADR
;output:R_SPI_DATA
SPI_READ:
		BCR			IO_RF_CSN
		MOVR  		R_SPI_ADR, TO_A
		MOVAR  		R_TEMP01
		LCALL 		SPI_RW
		LCALL 		SPI_RW
;		LCALL 		SPI_R
		MOVR  		R_TEMP01,  TO_A
		MOVAR  		R_SPI_DATA
		BSR			IO_RF_CSN
		RET
;;=========================================================
;input:R_SPI_ADR R_SPI_DATA
;output: nop
SPI_WRITE:
		BCR			IO_RF_CSN
		MOVR  		R_SPI_ADR,  TO_A
		MOVAR  		R_TEMP01
		LCALL 		SPI_RW
		MOVR  		R_SPI_DATA, TO_A
		MOVAR  		R_TEMP01
		LCALL 		SPI_RW
		BSR			IO_RF_CSN
		RET
;;=========================================================
;input: R_TEMP01
;output:R_TEMP01
SPI_RW:
		BCR			IO_RF_SCK
		MOVIA		8
		MOVAR		R_TEMP02
SPI_RW_LOOP:
		RLR			R_TEMP01, TO_R
		BTRSC		STATUS, C_B							;DATA, check C
		LGOTO		$+3
		BCR			IO_RF_MOSI
		LGOTO		$+2
		BSR			IO_RF_MOSI
		BSR			IO_RF_SCK

		BTRSS		IO_RF_MISO
		LGOTO		$+3
		BSR			R_TEMP01, 0
		LGOTO		$+2
		BCR			R_TEMP01, 0
		BCR			IO_RF_SCK
	
		DECRSZ		R_TEMP02, TO_R
		LGOTO		SPI_RW_LOOP
		BCR			IO_RF_MOSI
		RET
/*SPI_R:
		BCR			IO_RF_SCK
		BSR			IO_RF_MISO
		BANKSEL		TRISA
		BSR			DIR_RF_DATA
		BANKSEL		PORTA
		MOVIA		8
		MOVAR		R_TEMP02
SPI_R_LOOP:
		RLR			R_TEMP01, TO_R
		LJUMP		$+1
		LJUMP		$+1
		BSR			IO_RF_SCK
		BTSS		IO_RF_MISO
		LJUMP		$+3
		BSR			R_TEMP01, 0
		LGOTO		$+2
		BCR			R_TEMP01, 0
		BCR			IO_RF_SCK
		DECRSZ		R_TEMP02,TO_R
		LJUMP		SPI_R_LOOP
		BANKSEL		TRISA
		BCR			DIR_RF_DATA
		BANKSEL		PORTA
		BCR			IO_RF_MISO
		RET*/
;==========================================================
; input: R_RF_SEND_0 ~ R_RF_SEND_7
;==========================================================
RF_FIFO_RW:
		BCR			IO_RF_CSN
		MOVR		R_SPI_ADR, TO_A
		MOVAR		R_TEMP01
		LCALL		SPI_RW
		MOVIA		(R_RF_SEND_0-1)
			;MOVAR		R_TEMP03
			;MOVR		R_TEMP03,TO_A
		MOVAR		FSR
RF_FIFO_RW_LOOP:
			;INCR		R_TEMP03,TO_R
			;MOVAR		FSR
			INCR		FSR, TO_R
		MOVR		INDF, TO_A
		MOVAR		R_TEMP01
		LCALL		SPI_RW
		MOVR		R_TEMP01, TO_A
		MOVAR		INDF
		DECRSZ		R_RF_DATA_LEN, TO_R
		LGOTO		RF_FIFO_RW_LOOP
		BSR			IO_RF_CSN
		RET

/*RF_FIFO_R:
		BCR			IO_RF_CSN
		MOVR		R_SPI_ADR, TO_A
		MOVAR		R_TEMP01
		LCALL		SPI_RW
		MOVIA		(R_RF_SEND_0-1)
			;MOVAR		R_TEMP03
			;MOVR		R_TEMP03,TO_A
		MOVAR		FSR
RF_FIFO_R_LOOP:
			;INCR		R_TEMP03,TO_R
			;MOVAR		FSR
			INCR		FSR, TO_R
		MOVR		INDF, TO_A
		MOVAR		R_TEMP01
		LCALL		SPI_R
		MOVR		R_TEMP01, TO_A
		MOVAR		INDF
		DECRSZ		R_RF_DATA_LEN, TO_R
		LGOTO		RF_FIFO_R_LOOP
		BSR			IO_RF_CSN
		RET*/
;;=========================================================