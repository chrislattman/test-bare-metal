default:
	avr-gcc -Os -DF_CPU=16000000UL -mmcu=atmega2560 -o blink_led.elf blink_led.c
	# avr-objcopy -O ihex -R .eeprom blink_led.elf blink_led.hex # -j .text -j .data

test:
	avr-gcc -Og -ggdb3 -DF_CPU=16000000UL -mmcu=atmega2560 -o blink_led.elf blink_led.c

deploy:
	avrdude -F -V -D -p m2560 -c avrispmkII -P $(DEV) -b 115200 -U flash:w:blink_led.elf

deploy_qemu:
	qemu-system-avr -machine mega2560 -bios blink_led.elf -nographic -serial tcp::5678,server=on,wait=off
	# In another shell: telnet localhost 5678
	# Quit qemu: (qemu) quit
	# Quit telnet: Ctrl + ] -> telnet> quit

test_qemu:
	qemu-system-avr -machine mega2560 -bios blink_led.elf -nographic -S -s
	# To specify a different port, replace -s with -gdb tcp::<PORT>
	# In another shell:
	# gdb blink_led.elf
	# (gdb) target remote :1234
	# (gdb) break main
	# (gdb) continue

test_hardware:
	avrdude -p m2560 -c avrispmkII -P $(DEV) -b 115200 -T "disasm -gL flash 0 -1" > recovered.S
	avr-gcc -nostdlib -Wl,--section-start=.text=0x0000 -mmcu=atmega2560 -o recovered.elf recovered.S
	avrdude -qq -p m2560 -c avrispmkII -P $(DEV) -b 115200 -U flash:v:recovered.elf && echo OK # this takes about 30 s

clean:
	rm -rf *.elf *.hex *.o *.S
