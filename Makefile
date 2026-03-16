default:
	avr-gcc -Os -DF_CPU=16000000UL -mmcu=atmega2560 -o hello_world.elf hello_world.c
	# avr-objcopy -O ihex -R .eeprom hello_world.elf hello_world.hex # -j .text -j .data

test:
	avr-gcc -Og -ggdb3 -DTEST -DF_CPU=16000000UL -mmcu=atmega2560 -o hello_world.elf hello_world.c

deploy:
	avrdude -F -V -D -p m2560 -c avrispmkII -P $(DEV) -b 115200 -U flash:w:hello_world.elf

deploy_qemu:
	qemu-system-avr -machine mega2560 -bios hello_world.elf -nographic -serial telnet:localhost:5678,server=on,wait=off
	# In another shell: telnet localhost 5678
	# Quit qemu: (qemu) quit
	# Quit telnet: Ctrl + ] -> telnet> quit

test_qemu:
	qemu-system-avr -machine mega2560 -bios hello_world.elf -nographic -serial telnet:localhost:5678,server=on,wait=off -S -s
	# To specify a different GDB port, replace -s with -gdb tcp:localhost:<PORT>
	# In another shell:
	# gdb -q hello_world.elf
	# (gdb) target remote localhost:1234
	# (gdb) break main
	# (gdb) continue
	# In another shell: telnet localhost 5678

clean:
	rm -rf *.elf *.hex *.o *.S
