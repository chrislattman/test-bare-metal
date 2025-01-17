#include <avr/io.h>
#include <util/delay.h>

#define MS_DELAY 1000

int main(void) {
    /* The built-in LED is mapped to the 7th bit of port B (PORTB7):
     * https://docs.arduino.cc/resources/pinouts/A000067-full-pinout.pdf
     * Therefore, we want to set the 7th bit of the PORTB
     * Data Direction Register (DDRB). This puts the pin (digital pin 13)
     * corresponding to the LED in output mode. */
    DDRB |= _BV(DDB7);

    /* infinite loop */
    while (1) {
        PORTB |= _BV(PORTB7);   /* set PORTB7 to HIGH (turn on LED) */
        _delay_ms(MS_DELAY);    /* wait 1 second */
        PORTB &= ~_BV(PORTB7);  /* unset PORTB7 to LOW (turn off LED) */
        _delay_ms(MS_DELAY);    /* wait 1 second */
    }

    return 0;
}
