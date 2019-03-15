.syntax unified
.arch armv6-m
.thumb

.align 2
.section .interupt_vector, "a"

.global interupt_vector
interupt_vector:
    /* ARM Core System Handler Vectors */
    .word   _stack_top          @ Stack Pointer
    .word   Power_On_Reset      @ Reset
    .word   Default_Trap        @ NMI
    .word   Default_Trap        @ Hard Fault
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   Default_Trap        @ SV Call
    .word   0                   @ reserved
    .word   0                   @ reserved
    .word   Default_Trap        @ SRV Pending
    .word   Default_Trap        @ SysTick
    /* Non-Core Vectors */
    .word   Default_Trap        @ DMA ch 0, 4
    .word   Default_Trap        @ DMA ch 1, 5
    .word   Default_Trap        @ DMA ch 2, 6
    .word   Default_Trap        @ DMA ch 3, 7
    .word   Default_Trap        @ DMA errors
    .word   Default_Trap        @ FTFA
    .word   Default_Trap        @ PMC
    .word   Default_Trap        @ LLWU
    .word   Default_Trap        @ I2C0
    .word   0                   @ reserved
    .word   Default_Trap        @ SPI0
    .word   0                   @ reserved
    .word   Default_Trap        @ UART0
    .word   Default_Trap        @ UART1
    .word   Default_Trap        @ FlexCAN0
    .word   Default_Trap        @ ADC0
    .word   Default_Trap        @ ADC0
    .word   Default_Trap        @ FTM0
    .word   Default_Trap        @ FTM1
    .word   Default_Trap        @ FTM2
    .word   Default_Trap        @ CMP0
    .word   Default_Trap        @ CMP1
    .word   Default_Trap        @ FTM3
    .word   Default_Trap        @ WDOG/EWM
    .word   Default_Trap        @ FTM4
    .word   Default_Trap        @ DAC0
    .word   Default_Trap        @ FTM5
    .word   Default_Trap        @ MCG
    .word   Default_Trap        @ LPTMR0
    .word   Default_Trap        @ PDB0, PDB1
    .word   Default_Trap        @ PORT A
    .word   Default_Trap        @ PORT B, C, D, E

.align 1
.text

    .thumb_func
    .type Default_Trap, %function
Default_Trap:
    .weak Default_Trap
    nop
    b       Default_Trap
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
