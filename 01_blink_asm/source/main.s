@ MIT License
@
@ Copyright (c) 2019 Daniel Way
@ 
@ Permission is hereby granted, free of charge, to any person obtaining a copy
@ of this software and associated documentation files (the "Software"), to deal
@ in the Software without restriction, including without limitation the rights
@ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
@ copies of the Software, and to permit persons to whom the Software is
@ furnished to do so, subject to the following conditions:
@ 
@ The above copyright notice and this permission notice shall be included in all
@ copies or substantial portions of the Software.
@
@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
@ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
@ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
@ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
@ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
@ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
@ SOFTWARE.


.syntax unified
.arch armv6-m
.thumb


.text

.thumb_func
.global init
.type startup, %function
init:
    @ enable clock gating for PORT E
    .equ SIM_SCGC5, (0x40047000 + 0x1038)
    ldr     r1, =SIM_SCGC5
    movs    r0, #1
    lsls    r0, #13
    ldr     r2, [r1]
    orrs    r2, r0
    str     r2, [r1]

    @ set pin E29 as a GPIO
    .equ PORT_E, 0x4004D000
    ldr     r1, =PORT_E
    movs    r0, #7
    lsls    r0, #8      @ mask for mux field
    movs    r3, #1
    lsls    r3, #8      @ GPIO mux option
    ldr     r2, [r1, 0x74]
    bics    r2, r0
    orrs    r2, r3
    str     r2, [r1, 0x74]

    @ configure GPIO E pin 29 as output and set high (LED off)
    .equ GPIO_E, 0x400FF100
    ldr     r1, =GPIO_E
    movs    r0, #1
    lsls    r0, #29
    ldr     r2, [r1, 0x14]  @ PDDR read
    orrs    r2, r0
    str     r2, [r1, 0x14]  @ PDDR write
    str     r0, [r1, 0x8]   @ PCOR write
    bx      lr


.thumb_func
.global main
.type main, %function
main:
    .equ count, (72000000 / 10)
    ldr     r0, =count
    ldr     r1, =count

.L0:
    subs    r0, #1
    bgt     .L0
    bl      toggle_led
    movs    r0, r1
    b       .L0

.thumb_func
.global toggle_led
.type toggle_led, %function
toggle_led:
    push    {r0, r1}
    movs    r0, #1
    lsls    r0, #29
    ldr     r1, =GPIO_E
    str     r0, [r1, 0xC]   @ PTOR write
    pop     {r0, r1}
    bx      lr

.end
