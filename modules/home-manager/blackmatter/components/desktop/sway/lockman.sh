#!/bin/sh
# Times the screen off and puts it to background
swayidle \
	timeout 10 'swaymsg "output * dpms off"' \
	resume 'swaymsg "output * dpms on"' &

# immediate lock
swaylock \
	-e \
	-u \
	-i ~/backgrounds/nord/backgrounds/operating-systems/1920x1080/nixos.png

# kills background task so idle timer does not keep running
kill %%
