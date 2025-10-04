# Contains only theme and such

import os

config_home = os.environ["XDG_CONFIG_HOME"] if "XDG_CONFIG_HOME" in os.environ else os.path.expanduser("~/.config")
hostname = os.uname()[1]

themes = {
    "gruvbox": {
        "bg":      "#282828",
        "gray":    "#928374",
        "brgray":  "#a89984",
        "fg":      "#ebdbb2",
        "red":     "#cc231d",
        "bred":    "#fb4934",
        "green":   "#98971a",
        "bgreen":  "#b8bb26",
        "yellow":  "#d79921",
        "byellow": "#fabd2f",
        "blue":    "#458588",
        "bblue":   "#83a598",
        "purple":  "#b16286",
        "bpurple": "#d3869b",
        "aqua":    "#689d6a",
        "baqua":   "#8ec07c",
        "orange":  "#d65d0e",
        "borange": "#fe8019",
        "bg0_h":   "#1d2021",
        "bg0":     "#282828",
        "bg0_s":   "#32302f",
        "bg1":     "#3c3836",
        "bg2":     "#504945",
        "bg3":     "#665c54",
        "bg4":     "#7c6f64",
        "bg5":     "#928374",
        "fg4":     "#a89984",
        "fg3":     "#bdae93",
        "fg2":     "#d5c4a1",
        "fg1":     "#ebdbb2",
        "fg0":     "#fbf1c7",
        "wallpaper": config_home + "/qtile/wallpapers/darker_gruvbox.png",
        "wallpaper_alt": config_home + "/qtile/wallpapers/darker_despair.png"
    },
    "despair":  {
        "bg":      "#101010",
        "gray":    "#7c7c7c",
        "brgray":  "#8e8e8e",
        "fg":      "#b9b9b9",
        "red":     "#903a3a",
        "bred":    "#ce5252",
        "green":   "#6d7144",
        "bgreen":  "#9ca54e",
        "yellow":  "#af8431",
        "byellow": "#f0c674",
        "blue":    "#61837e",
        "bblue":   "#5f819d",
        "purple":  "#92729f",
        "bpurple": "#b48ac4",
        "aqua":    "#61837e",
        "baqua":   "#73b8af",
        "orange":  "#50616f",
        "borange": "#5f819d",
        "bg0_h":   "#101010",
        "bg0":     "#101010",
        "bg0_s":   "#252525",
        "bg1":     "#252525",
        "bg2":     "#7c7c7c",
        "bg3":     "#7c7c7c",
        "bg4":     "#8e8e8e",
        "bg5":     "#8e8e8e",
        "fg4":     "#b9b9b9",
        "fg3":     "#b9b9b9",
        "fg2":     "#e3e3e3",
        "fg1":     "#e3e3e3",
        "fg0":     "#f7f7f7",
        "wallpaper": config_home + "/qtile/wallpapers/darker_despair.png",
        "wallpaper_alt": config_home + "/qtile/wallpapers/darker_despair.png"
    }
}

selected_theme = "gruvbox"

if os.path.exists(config_home + "/env_theme_name"):
    f = open(config_home + "/env_theme_name")
    theme_conf = f.readlines()[0][:-1]
    if theme_conf in themes:
        selected_theme = theme_conf
    f.close()

# current theme
theme = themes[selected_theme]

if (hostname == "Mars" or hostname == "Helios") and selected_theme == "despair":
    theme["wallpaper"] = config_home + "/qtile/wallpapers/forest_desaturated.png"
