default:
	avr-gcc -Os -DF_CPU=16000000UL -mmcu=atmega2560 -o blink_led.elf blink_led.c
	avr-objcopy -O ihex -R .eeprom blink_led.elf blink_led.hex # -j .text -j .data

deploy:
	avrdude -F -V -D -c avrispmkII -p m2560 -P $(DEV) -b 115200 -U flash:w:blink_led.hex

clean:
	rm -rf *.elf *.hex
