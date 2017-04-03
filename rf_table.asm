TABLE_RF_ADR:
		MOVIA		7
		MOVAR		PCLATH
		MOVR		R_TEMP00,TO_A
		ADDAR		PCL, TO_R
		RETW		W_REGISTER+DYNPD					;0
		RETW		W_REGISTER+EN_RXADDR
		RETW		W_REGISTER+EN_AA
		RETW		SETUP_AW + W_REGISTER
		RETW		SETUP_RETR + W_REGISTER
		RETW		RX_PW_P0 + W_REGISTER
		RETW		FEATURE + W_REGISTER	
		RETW		RF_SETUP + W_REGISTER	
		RETW		DEM_CAL + W_REGISTER
		RETW		RF_CH + W_REGISTER			;9
TABLE_RF_DATA:
		MOVIA		7
		MOVAR		PCLATH
		MOVR		R_TEMP00,TO_A
		ADDAR		PCL, TO_R
		RETW		0		;初始化
		RETW		0X3F
		RETW		0X3F		
		RETW		0X02		;地址宽度4BYTE
		RETW		0X02		;
		RETW		C_RF_PACKET_SIZE		;RX payload的数据长度为8BYTE
		RETW		0X00		;CE由命令控制
		RETW		(C_RF8dBm|C_DR_1M)	;发射功率、码率
		RETW		0X03
		RETW		9
TABLE_RF_CHANNEL:
		MOVIA		7
		MOVAR		PCLATH
		MOVR		R_TEMP00,TO_A
		ADDAR		PCL, TO_R
		RETW		9
		RETW		61
		RETW		23
		RETW		77