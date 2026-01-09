local wezterm = require('wezterm')

-- https://github.com/Tecate/bitmap-fonts

local M = {
    -- https://github.com/microsoft/cascadia-code
    cascadia = {
        regular = {family = 'Cascadia Mono PL', weight = 'Regular', style = 'Normal', italic = false},
        size = 11,
        brighten = false,
        cell_width = 1.0,
        line_height = 1.0,
        rules = {
            {
                intensity = "Bold", italic = false,
                font = wezterm.font({family = 'Cascadia Mono PL', weight = 'Bold', style = 'Normal', italic = false})
            },
            {
                intensity = "Normal", italic = true,
                font = wezterm.font({family = 'Cascadia Mono PL', weight = 'Regular', style = 'Italic', italic = true})
            },
            {
                intensity = "Bold", italic = true,
                font = wezterm.font({family = 'Cascadia Mono PL', weight = 'Bold', style = 'Italic', italic = true})
            },
        }
    },

    -- https://github.com/IdreesInc/Miracode
    miracode = {
        regular = {family = 'Miracode', weight = 'Regular', style = 'Normal', italic = false},
        size = 11,
        brighten = true,
        cell_width = 1.0,
        line_height = 1.0,
        rules = {
            {
                intensity = "Bold", italic = false,
                font = wezterm.font({family = 'Miracode', weight = 'Regular', style = 'Normal', italic = false})
            },
            {
                intensity = "Normal", italic = true,
                font = wezterm.font({family = 'Miracode', weight = 'Regular', style = 'Normal', italic = true})
            },
            {
                intensity = "Bold", italic = true,
                font = wezterm.font({family = 'Miracode', weight = 'Regular', style = 'Normal', italic = true})
            },
        }
    },

    -- https://github.com/zshoals/Dina-Font-TTF-Remastered
    dina_remaster = {
        regular = {family = 'DinaRemaster', weight = 'Regular', style = 'Normal', italic = false},
        size = 12,
        brighten = false,
        cell_width = 1.0,
        line_height = 1.0,
        rules = {
            {
                intensity = "Bold", italic = false,
                font = wezterm.font({family = 'DinaRemaster', weight = 'Bold', style = 'Normal', italic = false})
            },
            {
                intensity = "Normal", italic = true,
                font = wezterm.font({family = 'DinaRemaster', weight = 'Regular', style = 'Normal', italic = false})
            },
            {
                intensity = "Bold", italic = true,
                font = wezterm.font({family = 'DinaRemaster', weight = 'Bold', style = 'Normal', italic = false})
            },
        }
    },

    -- https://github.com/sunaku/tamzen-font/
    tamzen = {
        regular = {family = 'Tamzen', weight = 'Regular', style = 'Normal', italic = false},
        size = 12,
        brighten = false,
        cell_width = 1.0,
        line_height = 1.0,
        rules = {
            {
                intensity = "Bold", italic = false,
                font = wezterm.font({family = 'Tamzen', weight = 'Bold', style = 'Normal', italic = false})
            },
            {
                intensity = "Normal", italic = true,
                font = wezterm.font({family = 'Tamzen', weight = 'Regular', style = 'Normal', italic = false})
            },
            {
                intensity = "Bold", italic = true,
                font = wezterm.font({family = 'Tamzen', weight = 'Bold', style = 'Normal', italic = false})
            },
        }
    },

    -- https://www.dcmembers.com/jibsen/download/61/
    dina = {
        regular = {family = 'Dina', weight = 'Regular', style = 'Normal', italic = false},
        size = 12,
        brighten = false,
        cell_width = 0.7,
        line_height = 1.0,
        rules = {
            {
                intensity = "Bold", italic = false,
                font = wezterm.font({family = 'Dina', weight = 'Bold', style = 'Normal', italic = false})
            },
            {
                intensity = "Normal", italic = true,
                font = wezterm.font({family = 'Dina', weight = 'Regular', style = 'Italic', italic = false})
            },
            {
                intensity = "Bold", italic = true,
                font = wezterm.font({family = 'Dina', weight = 'Bold', style = 'Italic', italic = false})
            },
        }
    },

    -- https://terminus-font.sourceforge.net/
    -- https://files.ax86.net/terminus-ttf/
    terminus = {
        regular = {family = 'Terminus', weight = 'Regular', style = 'Normal', italic = false},
        size = 12,
        brighten = false,
        cell_width = 1.0,
        line_height = 1.0,
        rules = {
            {
                intensity = "Bold", italic = false,
                font = wezterm.font({family = 'Terminus', weight = 'Bold', style = 'Normal', italic = false})
            },
            {
                intensity = "Normal", italic = true,
                font = wezterm.font({family = 'Terminus', weight = 'Regular', style = 'Normal', italic = false})
            },
            {
                intensity = "Bold", italic = true,
                font = wezterm.font({family = 'Terminus', weight = 'Bold', style = 'Normal', italic = false})
            },
        }
    },

    -- https://github.com/the-moonwitch/Cozette/releases/tag/v.1.30.0
    -- https://github.com/slavfox/Cozette
    cozette = {
        regular = {family = 'Cozette', weight = 'Medium', style = 'Normal', italic = false},
        size = 12,
    },

    cozette_hidpi = {
        regular = {family = 'CozetteHiDpi', weight = 'Medium', style = 'Normal', italic = false},
        size = 12,
    },

    -- https://github.com/TakWolf/ark-pixel-font
    -- 10px needs size 7
    ark_pixel10 = {
        regular = {family = 'Ark Pixel 10px M ja', weight = 'Regular', style = 'Normal', italic = false, scale = 0.65},
        size = 7,
    },

    -- 12px needs size 9
    ark_pixel12 = {
        regular = {family = 'Ark Pixel 12px M ja', weight = 'Regular', style = 'Normal', italic = false, scale = 0.75},
        size = 9,
    },

    -- 16px needs size 12
    ark_pixel16 = {
        regular = {family = 'Ark Pixel 16px M ja', weight = 'Regular', style = 'Normal', italic = false},
        size = 12,
    },

    -- https://github.com/stgiga/UnifontEX
    unifontex = {
        regular = {family = 'UnifontExMono', weight = 'Regular', style = 'Normal', italic = false},
        size = 12,
        line_height = 0.9,
        cell_width = 0.55
    },

    -- https://unifoundry.com/unifont/index.html
    unifont = {
        regular = {family = 'Unifont-JP', weight = 'Regular', style = 'Normal', italic = false},
        size = 12,
        cell_width = 0.55
    }
}
-- https://github.com/mshioda/relaxed-typing-mono-jp
return M

--[[
    12 px or 9 pt
    14 px or 10.5 pt
    16 px or 12 pt
    18 px or 13.5 pt
    20 px or 15 pt
    22 px or 16.5 pt
    24 px or 18 pt
    28 px or 21 pt
    32 px or 24 pt
]]
