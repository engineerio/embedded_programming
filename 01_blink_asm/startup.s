.syntax unified
.arch armv6-m
.thumb

.align 2
.section .interupt_vector, "a"

.global interupt_vector
interupt_vector:
    /* ARM Core System Handler Vectors */
    .word   _stack_top      @ Stack Pointer
    .word   Power_On_Reset  @ Reset
    .word   hang_loop       @ NMI
    .word   hang_loop       @ Hard Fault
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   hang_loop       @ SV Call
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   hang_loop       @ SRV Pending
    .word   hang_loop       @ SysTick
    /* Non-Core Vectors */
    .word   hang_loop       @ DMA ch 0, 4
    .word   hang_loop       @ DMA ch 1, 5
    .word   hang_loop       @ DMA ch 2, 6
    .word   hang_loop       @ DMA ch 3, 7
    .word   hang_loop       @ DMA errors
    .word   hang_loop       @ FTFA
    .word   hang_loop       @ PMC
    .word   hang_loop       @ LLWU
    .word   hang_loop       @ I2C0
    .word   0                   @ reserved
    .word   hang_loop       @ SPI0
    .word   0                   @ reserved
    .word   hang_loop       @ UART0
    .word   hang_loop       @ UART1
    .word   hang_loop       @ FlexCAN0
    .word   hang_loop       @ ADC0
    .word   hang_loop       @ ADC0
    .word   hang_loop       @ FTM0
    .word   hang_loop       @ FTM1
    .word   hang_loop       @ FTM2
    .word   hang_loop       @ CMP0
    .word   hang_loop       @ CMP1
    .word   hang_loop       @ FTM3
    .word   hang_loop       @ WDOG/EWM
    .word   hang_loop       @ FTM4
    .word   hang_loop       @ DAC0
    .word   hang_loop       @ FTM5
    .word   hang_loop       @ MCG
    .word   hang_loop       @ LPTMR0
    .word   hang_loop       @ PDB0, PDB1
    .word   hang_loop       @ PORT A
    .word   hang_loop       @ PORT B, C, D, E

.align 4
.text

    .macro irq_hang index
    movs    r0, \index
    ldr     r1, hang_loop
    bx      r1
    .endm

    .thumb_func
    .type hang_loop, %function
hang_loop:
    nop
    b       hang_loop


    .thumb_func
    .type wdog_hang, %function
wdog_hang:
    irq_hang #39
    

@   Start of code execution
@   Make sure to include "ENTRY(Power_On_Reset)" in the linker script
@   This function should also be referenced by the static NVIC reset handler

    .align 2
    .thumb_func
    .global Power_On_Reset
    .type Power_On_Reset, %function
Power_On_Reset:
    cpsid   i           @ disable all interupts durin startup
    .extern interupt_vector
    ldr     r1, =interupt_vector
    ldr     r0, [r1]    @ copy stack pointer from NVIC to SP register
    msr     msp, r0
    .equ    wdog_addr, 0x40052000
    ldr     r1, =wdog_addr
    ldrh    r2, [r1]        @ read WDOG_STCTRLH
    movs    r0, #1
    bics    r2, r0
    strh    r2, [r1]        @ write WDOG_STCTRLH

/* Clear BSS section */
bss_init:
    .extern _bss_start  @ defined in linker
    .extern _bss_end    @ defined in linker

    ldr     r1, =_bss_start
    ldr     r2, =_bss_end
    subs    r2, r1
    ble     .bss_init_end
    movs    r0, #0
.bss_zero_loop:
    subs    r2, #4
    str     r0, [r1, r2]
    bgt     .bss_zero_loop
.bss_init_end:


/* Initialize DATA section */
data_init:
    .extern _data_load_addr @ defined in linker
    .extern _data_start     @ defined in linker
    .extern _data_end       @ defined in linker

    ldr     r1, =_data_load_addr
    ldr     r2, =_data_start
    ldr     r3, =_data_end
    subs    r3, r2
    ble     .data_init_end
.data_move_loop:
    subs    r3, #4
    ldr     r0, [r2, r3]
    str     r0, [r1, r3]
    bgt     .data_move_loop
.data_init_end:

    bl      init        @ peripheral initialization code
    cpsie   i           @ enable interupts
    bl      main        @ branch to main program

.end
