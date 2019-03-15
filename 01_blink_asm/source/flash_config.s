.syntax unified
.arch armv6-m
.thumb
.align 2

/* Flash Configuration */
.section .FlashConfig, "a"
    .long 0xFFFFFFFF
    .long 0xFFFFFFFF
    .long 0xFFFFFFFF
    .long 0xFFFFFFFE

.end
