# xrandr --output HDMI-0 --rotate $1

id=$(xinput list --id-only "GAOMON Gaomon Tablet Pen")
# id=$(xinput list --id-only "input-remapper GAOMON Gaomon Tablet Pen forwarded stylus")
# id=$(xinput list --id-only "Wacom Bamboo One S Pen stylus")

# xsetwacom --set $id MapToOutput 1922x1080+4+352
xsetwacom --set $id MapToOutput 1922x1080+4+2
# xsetwacom --set $id MapToOutput 1920x1080+0+348

# xinput map-to-output $id HDMI-0


