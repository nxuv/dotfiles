# pylint disable=all

import subprocess
import os

from libqtile import hook

from apps import *
from groups import *
from keymap import *
from layouts import *
from screens import *

from typing import List

# ---------------------------------------------------------------------------- #
#                               ADDITIONAL CONFIG                              #
# ---------------------------------------------------------------------------- #

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
x11_drag_polling_rate = 60

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
# wmname = "LG3D"

# from libqtile.scripts.main import VERSION
# wmname = f"Qtile {VERSION}"
wmname = "Qtile"

@hook.subscribe.screen_change
def restart_on_randr(qtile, event):
    qtile.cmd_restart()
    qtile.to_screen(0)
    # qtile.to_screen(1)

@hook.subscribe.startup_once
def hook_startup_once():
    screens[0].toggle_group(group_names[1]) # center
    # screens[1].toggle_group(group_names[1]) # center
    # screens[0].toggle_group(group_names[2]) # right
    subprocess.Popen(home + "/.screenlayout/main.sh", env = os.environ)
    subprocess.Popen(home + "/.config/qtile/autostart.sh", env = os.environ)

