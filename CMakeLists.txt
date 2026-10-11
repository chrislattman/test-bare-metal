cmake_minimum_required(VERSION 3.27)

project(hello_world)

set(MCU atmega2560 CACHE STRING "Target MCU (passed to -mmcu)")
set(F_CPU 16000000UL CACHE STRING "CPU clock frequency")
set(DEV /dev/ttyACM0 CACHE STRING "Serial device of the programmer, used by the deploy target")

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE MinSizeRel CACHE STRING "Build type" FORCE)
endif()
set(CMAKE_C_FLAGS_DEBUG "-Og -ggdb3")
set(CMAKE_C_FLAGS_MINSIZEREL "-Os -DNDEBUG")

add_executable(hello_world hello_world.c)
set_target_properties(hello_world PROPERTIES SUFFIX ".elf")
target_compile_definitions(hello_world PRIVATE F_CPU=${F_CPU})
target_compile_options(hello_world PRIVATE -mmcu=${MCU})
target_link_options(hello_world PRIVATE -mmcu=${MCU})

set(ELF $<TARGET_FILE:hello_world>)

add_custom_target(deploy
    COMMAND avrdude -F -V -D -p m2560 -c avrispmkII -P ${DEV} -b 115200 -U flash:w:${ELF}
    DEPENDS hello_world
    USES_TERMINAL
    VERBATIM
)

# In another shell: telnet localhost 5678
# Quit qemu: (qemu) quit
# Quit telnet: Ctrl + ] -> telnet> quit
add_custom_target(qemu
    COMMAND qemu-system-avr -machine mega2560 -bios ${ELF} -nographic
            -serial telnet:localhost:5678,server=on,wait=off
    DEPENDS hello_world
    USES_TERMINAL
    VERBATIM
)

# Same as qemu, but halts at startup and waits for GDB on localhost:1234
# (replace -s with -gdb tcp:localhost:<PORT> to use a different port).
# In another shell (replace gdb-multiarch with avr-gdb if using macOS):
#   gdb-multiarch -q build/hello_world.elf
#   (gdb) target remote localhost:1234
#   (gdb) break main
#   (gdb) continue
# In another shell: telnet localhost 5678
add_custom_target(qemu_debug
    COMMAND qemu-system-avr -machine mega2560 -bios ${ELF} -nographic
            -serial telnet:localhost:5678,server=on,wait=off -S -s
    DEPENDS hello_world
    USES_TERMINAL
    VERBATIM
)
