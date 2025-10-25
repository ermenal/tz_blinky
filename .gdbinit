# .gdbinit - workspace helper for J-Link debugging
# Usage: start JLinkGDBServer (scripts/start_jlink_gdb_server.sh ...) then
# run: arm-none-eabi-gdb -x .gdbinit

set pagination off
set confirm off
tui enable
tui focus cmd

define reset
    # Reset device
    monitor reset
    # Flash device
    load
end
document reset
    Reset and reflash device
end

define usart0
    x/10x 0x5005c000
end

define sau_ctrl
    x/wx 0xE000EDD0
end


# Update the path below if you want to debug the non-secure build instead
target remote localhost:2331
file ./thesis_project_ns/build/debug/thesis_project_ns.out
#add-symbol-file ./thesis_project_s/build/debug/thesis_project_s.out
# file ./thesis_project_s/build/debug/thesis_project_s.out
monitor halt

# Helpful breakpoints
# voor s debuggen
#break main
#break Reset_Handler
#break SystemInit
#break _start
#break configure_sau


# voor ns debuggen
break delay
