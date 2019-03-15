    .syntax unified
    .arch armv6-m
    .thumb

    .text

    .equ    wdog_addr, 0x40052000

.section .text_wdog_refresh, "x"
    .thumb_func
    .global wdog_refresh
    .type wdog_refresh, %function
wdog_refresh:
    push    {r0, r1}
    cpsid   i
    ldr     r1, =wdog_addr
    .equ    refresh_1, 0xA602
    ldr     r0, =refresh_1
    strh    r0, [r1, 0xC]   @ write WDOG_REFRESH
    .equ    refresh_2, 0xB480
    ldr     r0, =refresh_2
    strh    r0, [r1, 0xC]   @ write WDOG_REFRESH
    cpsie   i
    pop     {r0, r1}
    bx      lr



.section .text_wdog_disable, "x"
.thumb_func
.global wdog_disable
.type wdog_disable, %function
@ .subsection wdog_disable
wdog_disable:
    push    {r0, r1, r2}
    cpsid   i
    ldr     r1, =wdog_addr
    .equ    unlock_1, 0xC520
    ldr     r0, =unlock_1
    strh    r0, [r1, 0xE]   @ write WDOG_UNLOCK
    .equ    unlock_2, 0xD928
    ldr     r0, =unlock_2
    strh    r0, [r1, 0xE]   @ write WDOG_UNLOCK
    ldrh    r2, [r1]        @ read WDOG_STCTRLH
    movs    r0, #1
    bics    r2, r0
    strh    r2, [r1]        @ write WDOG_STCTRLH
    cpsie   i
    pop     {r0, r1, r2}
    bx      lr

    .end
