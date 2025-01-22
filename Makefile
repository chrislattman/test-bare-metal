default:
	avr-gcc -Os -DF_CPU=16000000UL -mmcu=atmega2560 -o blink_led.elf blink_led.c
	avr-objcopy -O ihex -R .eeprom blink_led.elf blink_led.hex # -j .text -j .data

deploy:
	avrdude -F -V -D -p m2560 -c avrispmkII -P $(DEV) -b 115200 -U flash:w:blink_led.hex

test:
	avrdude -p m2560 -c avrispmkII -P $(DEV) -b 115200 -T "disasm -gL flash 0 -1" > recovered.S
	avr-gcc -nostdlib -Wl,--section-start=.text=0x0000 -mmcu=atmega2560 -o recovered.elf recovered.S
	avrdude -qq -p m2560 -c avrispmkII -P $(DEV) -b 115200 -U flash:v:recovered.elf && echo OK # this takes about 30 s

clean:
	rm -rf *.elf *.hex *.o *.S
