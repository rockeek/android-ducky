#numlock off: 01
#numlock on: 00
if [ $(echo numlock | ./hid-gadget-test /dev/hidg0 keyboard | tr -dc '0-9') -gt 0 ]; then echo numlock | ./hid-gadget-test /dev/hidg0 keyboard; fi > /dev/null