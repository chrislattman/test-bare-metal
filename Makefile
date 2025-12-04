default:
	avr-gcc -Os -DF_CPU=16000000UL -mmcu=atmega2560 -o blink_led.elf blink_led.c
	# avr-objcopy -O ihex -R .eeprom blink_led.elf blink_led.hex # -j .text -j .data

test:
	avr-gcc -Og -ggdb3 -DTEST -DF_CPU=16000000UL -mmcu=atmega2560 -o blink_led.elf blink_led.c

deploy:
	avrdude -F -V -D -p m2560 -c avrispmkII -P $(DEV) -b 115200 -U flash:w:blink_led.elf

deploy_qemu:
	qemu-system-avr -machine mega2560 -bios blink_led.elf -nographic -serial telnet::5678,server=on,wait=off
	# In another shell: telnet localhost 5678
	# Quit qemu: (qemu) quit
	# Quit telnet: Ctrl + ] -> telnet> quit

test_qemu:
	qemu-system-avr -machine mega2560 -bios blink_led.elf -nographic -serial telnet::5678,server=on,wait=off -S -s
	# To specify a different GDB port, replace -s with -gdb tcp::<PORT>
	# In another shell:
	# gdb -q blink_led.elf
	# (gdb) target remote :1234
	# (gdb) break main
	# (gdb) continue
	# In another shell: telnet localhost 5678

clean:
	rm -rf *.elf *.hex *.o *.S
