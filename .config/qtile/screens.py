# Screens or monitors

from libqtile import bar
from libqtile.config import Screen

from widgets import init_widgets, init_widgets_part, bar_color, bar_margin
from theme import theme

screen_order    = [0, 1, 2]

screen_screens  = [
    Screen( # left
        top = bar.Bar(widgets = init_widgets_part(), size = 24, margin = bar_margin, background = bar_color, ),
        wallpaper=theme["wallpaper_left"],
        wallpaper_mode='stretch', ),
    Screen( # center
        top = bar.Bar(widgets = init_widgets(), size = 24, margin = bar_margin, background = bar_color, ),
        # wallpaper=home + '/.config/qtile/wallpapers/center.png', # girl in center
        wallpaper =theme["wallpaper_center"],
        wallpaper_mode='stretch', ),
    Screen( # right
        top = bar.Bar(widgets = init_widgets_part(), size = 24, margin = bar_margin, background = bar_color, ),
        wallpaper=theme["wallpaper_right"],
        wallpaper_mode='stretch', ),
    ]

# Init as center right left then swap left around
# should be:
# | *** | DEV | Window Name                       Upd:  45 | Mem:  53% | CPU:   3% | Doom | Up | Time | V |
screens = [
        # screen_screens[screen_order[0]],
        screen_screens[screen_order[1]],
        screen_screens[screen_order[2]],
]

