# GPIO in Assembly Example

This repository shows a complete example to flash a single LED hooked up to
a Raspberry Pi 3's GPIO. This uses ARMv7, but the same techniques can easily
be used in ARMv8 with a few modifications. This repository is meant as a means
to relay information directly to my teammates on a school project. The code was
adapted from Robert G Plantz's website, and [can be found here](
https://bob.cs.sonoma.edu/IntroCompOrg-RPi/chp-gpio.html). Please refer to this
link for a much more in depth explanation of the code.

## Contents

* `gpio.py` - Python example using wiringPi to turn LED on/off.
* `gpio.s` - An example flashing an LED using the wiringPI library with assembly
* `gpio_main.s` - Main function
* `gpio_mem.s` - Function that finds and maps the GPIO memory space to be
accessed by the program
* `gpio_sel.s` - Function analagous to `pinMode()`. Sets the pin mode for the pin
* `gpio_set.s` - Function analagous to `digitalWrite(#, HIGH)`. Turns the LED on.
* `gpio_clr.s` - Function analagous to `digitalWrite(#, LOW)`. Turns LED off.

## Explanation

On a Raspberry Pi, the GPIO pins map to memory address location. They can be
directly modified using these memory locations. More information can be found
using the [datasheet](
https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf)
about the direct mappings. In particular, the memory locations can be found in
`/dev/gpiomem` on the Raspberry Pi.

`getMemAddr` is defined inside of `gpio_mem.s` and takes care of this task. It
uses the `mmap` built in function to  map a memory location to the processes'
page file. After the memory is mapped, the other functions can be called to
modify the pins. When the process completes `munmap` is called which releases
the page file. This mapping is in real time, and any change made will be
directly mapped to `/dev/gpiomem`, resulting in the GPIO being accessed.

Each function uses a certain range of memory inside of the mem file. These
ranges act as registers for the GPIO and are 32-bits wide. All of the registers
start at the offset `0x200000` from the periphals memory location. `GPIOSELn`
is the field that sets the mode for each GPIO pin. Each GPIO pin is controlled
by three pins and has 8 modes. The next range used is the `GPIOSETn` which
controls if the pin is activated or not. Finally, we use `GPIOCLRn` to turn
the pin off.

`getMemAddr` must be called every time a GPIO pin needs to be modified or set
up in order map the memory into the process's page file. If the process does not
have access to the memory location, the program will end in a segfault.

Before any data can be written to a pin, the pin needs to be set up in the
OUTPUT mode. On the raspberry pi, the command `gpio readall` will show which
mode each pin is currently in, as well as the numbering schema for the pins.
When using assembly to access the pins, the BCM column is referred for the pin
number. There are 8 different pin modes to choose from. The most common are
INPUT and OUTPUT, which are the values 0b000 and 0b001, respectively. This only
needs to be done once. The GPIO mode is maintained until the system is shut off.
When the system first boots up, the GPIO is set to be INPUT for default on each
pin.

After the pin mode has been set, we can now write to the pin as needed. When
using most libraries, turning the pin on and off has usually been delegated to
a single function. However, the GPIO has two different memory locations that
need to be written. Writing a 0 to the `GPIOSETn` register in memory has
absolutely no effect on the pin. In order to turn off the LED we write a 1 to
corresponding bit in the `GPIOCLRn` register. The code to access `GPIOSETn` and
`GPIOCLRn` is exactly the same; only the register offset is changed in the
source.
