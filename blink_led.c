#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>

#define MS_DELAY            1000
#define BAUD_RATE           115200UL
#define SERIAL_FORMAT_8N1   0x06

FILE* usart_init(void);
static int usart_putc(char c, FILE *stream);

static FILE outfile = FDEV_SETUP_STREAM(usart_putc, NULL, _FDEV_SETUP_WRITE);

static int usart_putc(char c, FILE *stream)
{
    loop_until_bit_is_set(UCSR0A, UDRE0);   /* wait until transmit buffer is empty */
    UDR0 = (uint8_t)c;                      /* load the transmit buffer with the character */
    return c;
}

FILE* usart_init(void)
{
    /* configure USART0 baud rate */
    UBRR0H = 0;
    UBRR0L = (uint8_t) (F_CPU / 4 / BAUD_RATE - 1) / 2;

    /* set USART0 control and status registers (UCSR0x) */
    UCSR0A |= _BV(U2X0);        /* double the transmission speed */
    UCSR0B |= _BV(TXEN0);       /* enable the USART0 transmitter */
    UCSR0C = SERIAL_FORMAT_8N1; /* guarantees character siZe to be 8 bits
                                 * regardless of UCSZn2 value */

    return &outfile;
}

int main(void) {
    /* stdout is mapped to USART0 */
    stdout = usart_init();

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
        puts("Hello");          /* print "Hello\n" to stdout (USARTO) */
        PORTB &= ~_BV(PORTB7);  /* unset PORTB7 to LOW (turn off LED) */
        _delay_ms(MS_DELAY);    /* wait 1 second */
        puts("World!");         /* print "World!\n" to stdout (USART0) */
    }

    return 0;
}
