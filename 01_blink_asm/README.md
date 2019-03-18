# LED Blinking Program Written in ARM Assembly
This is the first project written for the NXP FRDM-KV11Z microcontroller development board.
The functionality is very simple and the program flow is completely sequential

1. Disable watchdog timer
2. Initialize `.data` and `.bss` sections
3. Initialize GPIO pin connected to LED
    i. Enable clock gating to GPIO Port E
    ii. Set pin E29 as a digital pin
    iii. Configure pin E29 as an output
4. Brance to main program
    i. Busy wait by counting down a register value
    ii. When the register value reaches 0, toggle the pin controlling the LED
    iii. Branch to (i)
