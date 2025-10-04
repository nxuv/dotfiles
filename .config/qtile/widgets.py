# Widgets

from libqtile import widget, qtile

from icons import icons
from theme import theme

import apps as apps

bar_margin = [5, 5, 2, 5]
bar_opacity = "bb"
bar_color =   theme["bg"]

colors = {
    "main":   theme["orange"],
    "accent": theme["fg"],
    "off":    theme["bg5"],
}

widget_defaults = {
    "font":       icons["text_font"],
    "fontsize":   icons["text_size"],
    "padding":    3,
    # "font":       "Cascadia Mono PL",
    # "fontsize":   13,
    # "padding":    3,
    "foreground": colors["accent"]
}

sep_def = {
    "linewidth": 1,
    "padding":   6
}

spacer_def = {
    "length": 12
}

gr_def = {
    "foreground": colors["main"],
    "padding":    4,

    "font":       icons["icon_font"],
    # "font":       "Cascadia Mono PL",
    "fontsize":   icons["icon_size"],
}

fa_def = {
    "foreground": colors["main"],
    "padding":    3,

    "font":       icons["icon_font"],
    # "font":       "Material Design Icons",
    "fontsize":   icons["icon_size"], # 36
}

im_def = {
    "margin": 0,
    "scale": False
}

widget_volume = widget.PulseVolume(
    step = 5,
    fmt =  "{}",
    mute_format = "muted",
    mute_foreground = colors["off"],
    **widget_defaults
)

# ---------------------------------------------------------------------------- #
#                                MAIN SCREEN BAR                               #
# ---------------------------------------------------------------------------- #

widgets = {
    "groups": (lambda: widget.GroupBox(
        disable_drag = True,
        rounded = False,
        use_mouse_wheel = False,
        highlight_method = "line",
        active = colors["main"],
        inactive = colors["off"],
        borderwidth = 2,
        # this_current_screen_border = theme["bgreen"],
        # other_current_screen_border = theme["bred"],
        # this_screen_border = theme["byellow"],
        # other_screen_border = theme["baqua"],
        this_current_screen_border = theme["bg2"],
        other_current_screen_border = theme["bg0"],
        this_screen_border = theme["bg2"],
        other_screen_border = theme["bg0"],
        highlight_color = [bar_color, bar_color],
        **gr_def
    )),

    "spacer": (lambda: widget.Spacer(**spacer_def)),

    "window_name": (lambda: widget.WindowName(
        **widget_defaults,
        parse_text = lambda text: "" if text is None else ( text.rsplit("— ", 1)[1] if text.find("— ") != -1 else text )
    )),

    "wc_text": (lambda: widget.WindowCount(
        **widget_defaults,
        fmt = "{}"
    )),

    "lastfm_text": (lambda: widget.GenPollCommand(
        **widget_defaults,
        cmd = apps.home + "/.dotfiles/scripts/lastfm.sh",
        update_interval = 5,
        fmt = "{}",
    )),

    "mic_text": (lambda: widget.GenPollCommand(
        **widget_defaults,
        cmd = apps.home + "/.dotfiles/scripts/mic_check.sh",
        update_interval = 5, # In seconds
        fmt = "{}"
    )),

    "update_text": (lambda: widget.CheckUpdates(
        **widget_defaults,
        # distro = "Arch",
        custom_command = "yay -Qu",
        custom_command_modify = lambda x: x - 1,
        update_interval = (60) * 30, # Update time in seconds ( (60) * mins )
        display_format = "{updates}",
        no_update_string = " 0",
        mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(apps.term_exec + 'yay -Qu' + apps.term_wait)},
        colour_have_updates = colors["accent"],
        colour_no_updates = colors["off"],
    )),

    "disk_text": (lambda: widget.DF(
        **widget_defaults,
        format="{r:2.0f}%",
        partition = "/",
        measure = "M",
        mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(apps.terminal + ' btop')},
        visible_on_warn = False
    )),

    "ram_text": (lambda: widget.Memory(
        **widget_defaults,
        format="{MemPercent:2.0f}%",
        mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(apps.terminal + ' btop')},
    )),

    "cpu_text": (lambda: widget.CPU(
        **widget_defaults,
        format="{load_percent:2.0f}%",
        mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(apps.terminal + ' btop')},
    )),

    "volume_text": (lambda: widget_volume),

    "calendar_text": (lambda: widget.Clock(
        **widget_defaults,
        format="%d/%m",
        mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(apps.term_exec + 'ncal -yMb' + apps.term_wait)},
    )),

    "clock_text": (lambda: widget.Clock(
        **widget_defaults,
        format="%H:%M:%S",
        mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(apps.term_exec + 'ncal -yMb' + apps.term_wait)},
    )),

    "systray": (lambda: widget.WidgetBox(
        **fa_def,
        close_button_location='left',
        text_closed = icons["systray_opened"],
        text_open = icons["systray_closed"],
        widgets = [
            widget.Systray(**fa_def),
            widget.Spacer(**spacer_def),
            # widget.CurrentLayoutIcon(**fa_def, custom_icon_paths = ["~/.config/qtile/icons/layouts/"]),
            widget.CurrentLayout(**fa_def, mode='icon', custom_icon_paths = ["~/.config/qtile/icons/layouts/"]),
            widget.Spacer(**spacer_def),
        ]
    )),

    "screen": (lambda: widget.CurrentScreen(
        **fa_def,
        active_text = icons["screen_focus"],
        inactive_text = icons["screen_nofocus"],
        active_color = colors["main"],
        inactive_color = colors["off"],
    )),

    "keyboard": (lambda: widget.TextBox(
        **fa_def,
        text = icons["keyboard"],
        mouse_callbacks = {'Button1': lambda: qtile.cmd_spawn(apps.screen_keyboard)},
    )),


    # "update_icon"  : (lambda: widget.Image( **im_def, filename = images["update"])),
    # "disk_icon"    : (lambda: widget.Image( **im_def, filename = images["disk"])),
    # "ram_icon"     : (lambda: widget.Image( **im_def, filename = images["ram"])),
    # "cpu_icon"     : (lambda: widget.Image( **im_def, filename = images["cpu"])),
    # "volume_icon"  : (lambda: widget.Image( **im_def, filename = images["volume"])),
    # "calendar_icon": (lambda: widget.Image( **im_def, filename = images["calendar"])),
    # "clock_icon"   : (lambda: widget.Image( **im_def, filename = images["clock"])),

    "wc_icon"      : (lambda: widget.TextBox( **fa_def, text = icons["wcount"])),
    "lastfm_icon"  : (lambda: widget.TextBox( **fa_def, text = icons["music"])),
    "update_icon"  : (lambda: widget.TextBox( **fa_def, text = icons["update"])),
    "disk_icon"    : (lambda: widget.TextBox( **fa_def, text = icons["disk"])),
    "ram_icon"     : (lambda: widget.TextBox( **fa_def, text = icons["ram"])),
    "cpu_icon"     : (lambda: widget.TextBox( **fa_def, text = icons["cpu"])),
    "volume_icon"  : (lambda: widget.TextBox( **fa_def, text = icons["volume"])),
    "calendar_icon": (lambda: widget.TextBox( **fa_def, text = icons["calendar"])),
    "clock_icon"   : (lambda: widget.TextBox( **fa_def, text = icons["clock"])),
    "mic_icon"     : (lambda: widget.TextBox( **fa_def, text = icons["mic"])),
}

def init_widgets():
    return [
        widgets["groups"](),

        widgets["window_name"](),

        widgets["wc_icon"](),
        widgets["wc_text"](),

        widgets["spacer"](),
        widgets["lastfm_icon"](),
        widgets["lastfm_text"](),

        widgets["spacer"](),
        widgets["mic_icon"](),
        widgets["mic_text"](),

        widgets["spacer"](),
        widgets["update_icon"](),
        widgets["update_text"](),

        widgets["spacer"](),
        widgets["disk_icon"](),
        widgets["disk_text"](),

        widgets["spacer"](),
        widgets["ram_icon"](),
        widgets["ram_text"](),

        widgets["spacer"](),
        widgets["cpu_icon"](),
        widgets["cpu_text"](),

        widgets["spacer"](),
        widgets["volume_icon"](),
        widgets["volume_text"](),

        widgets["spacer"](),
        widgets["calendar_icon"](),
        widgets["calendar_text"](),

        widgets["spacer"](),
        widgets["clock_icon"](),
        widgets["clock_text"](),

        widgets["spacer"](),
        widgets["systray"](),

        widgets["spacer"](),
        widgets["screen"](),

        widgets["spacer"](),
    ]


# ---------------------------------------------------------------------------- #
#                                SIDE SCREEN BAR                               #
# ---------------------------------------------------------------------------- #

def init_widgets_part():
    return [
        widgets["groups"](),
        widgets["window_name"](),

        widgets["calendar_icon"](),
        widgets["calendar_text"](),

        widgets["spacer"](),
        widgets["clock_icon"](),
        widgets["clock_text"](),

        widgets["spacer"](),
        widgets["keyboard"](),

        widgets["spacer"](),
        widgets["screen"](),

        widgets["spacer"](),

    ]


