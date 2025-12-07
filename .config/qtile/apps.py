# Apps for use with keymap.py

import os
from libqtile.utils import guess_terminal

def is_tool(name):
    # Check whether `name` is on PATH and marked as executable
    # from whichcraft import which
    from shutil import which
    return which(name) is not None

def fimg(mods):
    return home + f"/.config/qtile/images/{mods}.png "

shell = "bash"
if (is_tool("fish")):
    shell = "fish"

if (is_tool("zsh")):
    shell = "zsh"

terminal        = guess_terminal()
terminal_exec   = terminal
term_exec       = terminal + " -x " + shell + " -c \""
term_wait       = " && read -p '' -n1 -s\""
term_end        = "\""

if (is_tool("kitty")):
    terminal      = "kitty"
    terminal_exec = "kitty"
    term_exec     = terminal_exec + " " + shell + " -c \""

if (is_tool("wezterm")):
    terminal      = "wezterm"
    terminal_exec = "wezterm -e"
    term_exec     = terminal_exec + " " + shell + " -c \""

def env_exec(cmd):
    # 0.2 seems to be smallest value to allow stuff to resize correctly
    return terminal_exec + " -- " + os.environ.get("SHELL", "sh") + " -c '" + cmd + "'"

def env_gui(cmd):
    return os.environ.get("SHELL", "sh") + " -c '" + cmd + "'"

# Makes qtile win the resizing race
def unrace_exec(cmd):
    # 0.2 seems to be smallest value to allow stuff to resize correctly
    return env_exec("sleep 0.2 && " + cmd)

home            = os.path.expanduser('~')
dotfiles        = home + "/.dotfiles"
# altbrowser      = "vivaldi-stable"
mybrowser       = "qutebrowser"
altbrowser      = "qutebrowser"

if (is_tool("min-browser")):
    altbrowser = "min-browser"

if (is_tool("falkon")):
    altbrowser = "falkon"

# browser_private = "qutebrowser --target private-window"
filemanager     = unrace_exec("ranger")
filemanager_gui = "nemo"
editor          = unrace_exec("nvim")
editor_gui      = "code"
process_explr   = unrace_exec("btop")
osc_draw        = "gromit-mpx"
music_player    = unrace_exec("musikcube")
modern_tracker  = "milkytracker"
fast_tracker    = "ft2-clone"
calculator      = "kcalc"
# spawnshortcuts  = "qutebrowser --target private-window -R " + dotfiles + "/.shortcuts.html"
spawnshortcuts = "feh "                    + \
                 fimg("mod4")              + \
                 fimg("mod4-mod1-control") + \
                 fimg("no_modifier")       + \
                 fimg("shift")             + \
                 fimg("mod4-mod1-shift")   + \
                 fimg("mod4-control")      + \
                 fimg("mod4-mod1")         + \
                 fimg("mod4-shift")

steam      = "steam"
beeper     = "beeper"
rustdesk   = "rustdesk"
screenshot = "flameshot gui"
screenrec  = "peek"
color_pick = "gpick"

rofi_launcher   = "rofi -show drun"     # Run apps (.desktop)
rofi_run        = "rofi -show run" # Run bin
rofi_window     = "rofi -show window" # All screens
rofi_windowcd   = "rofi -show windowcd" # Current screen
# rofi_launcher   = home + "/.config/rofi/launchers/type-4/launcher.sh"     # Run apps (.desktop)
# rofi_powermenu  = home + "/.config/rofi/powermenu/type-1/powermenu.sh"    # Power menu
rofi_powermenu = "rofi -show powermenu -modi powermenu:rofi-power-menu"
# rofi_run        = home + "/.config/rofi/launchers/type-4/launcher-run.sh" # Run bin
# rofi_window     = home + "/.config/rofi/launchers/type-4/launcher-win.sh" # All screens
# rofi_windowcd   = home + "/.config/rofi/launchers/type-4/launcher-wcd.sh" # Current screen
rofi_websearch  = home + "/.config/rofi/applets/rofi-search.sh"
rofi_pass       = home + "/.dotfiles/bin/pass-rofi-gui"

screen_keyboard = "onboard -x " + str(round(1920 + 1920 / 6))

# rofi_launcher = "rofi -show drun" # Run apps (.desktop)
# rofi_power_menu = "rofi -show power-menu -modi \"power-menu:rofi-power-menu --no-symbols\"" # Power menu
# rofi_run = "rofi -show run" # Run bin
# rofi_window = "rofi -show window" # All screens
# rofi_windowcd = "rofi -show windowcd" # Current screen
# rofi_websearch = ""

tabletscript = dotfiles + "/scripts/maptotablet.sh"
touchsscript = dotfiles + "/scripts/maptotouchs.sh"

amnesia_vpn = "AmneziaVPN"



