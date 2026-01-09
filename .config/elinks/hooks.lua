---@diagnostic disable: unused-vararg, deprecated, unused-local, unused-function, lowercase-global, undefined-global, param-type-mismatch, cast-local-type, undefined-field, need-check-nil

local config = {
    remove = {
        style = true,
        style_aggressive = true,
        head_links = true,
    },
    underline = {
        h1 = false,
        h2 = false,
        h3 = false,
    }
}

package.path = package.path .. ";" ..
    elinks_home .. "?.lua;" ..
    elinks_home .. "lua/?.lua;" ..
    elinks_home .. "lua/syntax/?.lua;"

local htmlparser = require("gumbo")
-- https://github.com/orbitalquark/scintillua/tree/default/lexers
local htmlsyntax = require("syntax")
local markdown = require("markdown")

require "utils"

local sourcehut = require("sourcehut")

----------------------------------------------------------------------
-- hooks
----------------------------------------------------------------------

pre_format_html_hooks = {n=0}
function pre_format_html_hook(url, html)
    local changed = nil
    for i, fn in ipairs(pre_format_html_hooks) do
        local new, stop = fn(url, html)
        if new then html = new; changed = 1 end
    end

    return changed and html
end

goto_url_hooks = {n=0}
function goto_url_hook(url, current_url)
    for i, fn in ipairs(goto_url_hooks) do
        local new, stop = fn(url, current_url)
        url = new
    end

    return url
end
-- IMPORTANT: do not leave empty, it will crash everything you hold dear
-- follow_url_hooks = {n=0}
-- function follow_url_hook(url)
--     for i, fn in ipairs(follow_url_hooks) do
--         local new, stop = fn(url)
--         url = new
--     end
--
--     return url
-- end

-- quit_hooks = {n=0}
-- function quit_hook(url, html)
--     for i, fn in ipairs(quit_hooks) do
--         fn()
--     end
-- end

----------------------------------------------------------------------
--  case-insensitive string.gsub
----------------------------------------------------------------------

-- Please note that this is not completely correct yet.
-- It will not handle pattern classes like %a properly.
-- FIXME: Handle pattern classes.

local function gisub(s, pat, repl, n)
    pat = string.gsub(pat, '(%a)',
	        function(v) return '['..string.upper(v)..string.lower(v)..']' end)
    if n then
        return string.gsub(s, pat, repl, n)
    else
        return string.gsub(s, pat, repl)
    end
end

----------------------------------------------------------------------
-- adding hooks
----------------------------------------------------------------------

-- Case insensitive
function starts_with(url, prefix)
    return string.sub(string.lower(url), 1, #prefix) == prefix
end

-- Case insensitive
function ends_with(url, postfix)
    return string.sub(string.lower(url), #url + 1 - #postfix, #url) == postfix
end

local function bang_search(url)
    if url == nil then return nil, nil end

    if url:sub(1, 1) == "!" then
        return "https://surf.sily.dev/?q=" .. url
    end

    return url
end
table.insert(goto_url_hooks, bang_search)

-- local function follow_slash(url)
--     if url == nil then return nil, nil end
--     _ALERT("Url = " .. url)
--     _ALERT("New = " .. url:sub(1, 7))
--     _ALERT("Res = " .. url:sub(8, #url))
--     if url:sub(1, 7) == "file://" then
--         if url:sub(8, #url):sub(1, 1) == "/" then
--             return "." .. url:sub(8, #url)
--         end
--     end
--     return url
-- end
-- table.insert(follow_url_hooks, follow_slash)

-- Don't take localhost as directory name
-- local function expand_localhost(url)
--     if not match("localhost", url) then return url, nil end
--
--     return "http://"..url, nil
-- end
-- table.insert(goto_url_hooks, expand_localhost)

----------------------------------------------------------------------
--  pre_format_html_hook
----------------------------------------------------------------------

-- syntax on <pre data-language="c">

local function process_code_tags(document)
    -- if true then return end
    local pres = document:getElementsByTagName("pre")
    for _, pre in ipairs(pres) do
        local data_language = pre:getAttribute("data-language")
        if data_language then
            -- Fix for `docs perl open-FILEHANDLE` code blocks
            local code_tags = pre:getElementsByTagName("code")
            for _, el_code in ipairs(code_tags) do
                local el_text = document:createTextNode(el_code.innerHTML)
                pre:replaceChild(el_text, el_code)
            end

            -- local hr
            -- hr = document:createElement("hr")
            -- pre.parentNode:insertBefore(hr, pre)
            -- hr = document:createElement("hr")
            -- pre.parentNode:insertBefore(hr, pre.nextSibling)

            local pre_code = pre.innerHTML;
            -- Fix for perl docs in general.
            -- Usually you wouldn't see &gt; used anywhere
            -- outside of web so I'll just assume it's not
            -- intended to be there, particularly in code
            -- blocks, unless it's html where we do want
            -- those.
            -- Possibly might affect javascript but we'll see
            pre_code = string.gsub(pre_code, "&gt;", ">")
            pre_code = string.gsub(pre_code, "&lt;", "<")
            pre_code = string.gsub(pre_code, "&amp;", "&")

            local code, err = htmlsyntax.highlight_to_html(
                data_language,
                pre_code,
                { class_prefix = "token_" }
            )

            -- See above
            if data_language ~= "html" then
                code = string.gsub(code, "&gt;", ">")
                code = string.gsub(code, "&lt;", "<")
                code = string.gsub(code, "&amp;", "&")
            end

            -- if err then _ALERT(err) else
            if not err then
                local element = htmlparser.parse(code, { contextElement = "pre" })
                local e = element.documentElement.childNodes[1]
                e:removeAttribute("class")
                e:setAttribute("data-language", data_language)
                pre.parentNode:replaceChild(e, pre)
            end
        end
    end
    -- TODO: config.surround?
    -- local codes = document:getElementsByTagName("code")
    -- for _, code in ipairs(codes) do
    --     local e = document:createElement("span")
    --     e.textContent = "["
    --     code.parentNode:insertBefore(e, code)
    --     e = document:createElement("span")
    --     e.textContent = "]"
    --     code.parentNode:insertBefore(e, code.nextSibling)
    -- end
end

-- url is current url
-- html is current page source, doesn't have to be html
local function pre_parse_html(url, html)
    if starts_with(url, "gemini://") then return html, false end
    if starts_with(url, "gopher://") then return html, false end
    if starts_with(url, "mailto://") then return html, false end
    if starts_with(url, "telnet://") then return html, false end
    if starts_with(url, "irl://")    then return html, false end
    if starts_with(url, "imap://")   then return html, false end
    if starts_with(url, "smtp://")   then return html, false end
    if starts_with(url, "ssh://")    then return html, false end

    if starts_with(url, "file://") then
        if ends_with(url, ".md") then
            set_option("toggle-html-plain", true)
            return "<!doctype html><html><body>" .. markdown(html) .. "</body></html>"
        end
        return html, false
    end
    -- if true then return html, false end

    local document = htmlparser.parse(html)
    local head = document.head

    if config.remove.head_links then
        remove_tags(head, "link")
        -- TODO: remove only icon/rel/preload/css
    end

    remove_tags(document, "script")
    remove_tags(document, "template")

    if config.remove.style or config.remove.style_aggressive then
        remove_tags(document, "style")
    end

    if config.remove.style_aggressive then
        for node in document.documentElement:walk() do
            if node.removeAttribute then
                if node:hasAttribute("style") then
                    node:removeAttribute("style")
                end
            end
        end
    end


    if config.underline.h1 then
        insert_hr_after_tag(document, "h1")
    end
    if config.underline.h2 then
        insert_hr_after_tag(document, "h2")
    end
    if config.underline.h3 then
        insert_hr_after_tag(document, "h3")
    end

    -- TODO: config.prefix?
    -- insert_text_in_tag(document, "h1", "#")
    -- insert_text_in_tag(document, "h2", "#")
    -- insert_text_in_tag(document, "h3", "#")
    -- insert_text_in_tag(document, "h4", "#")
    -- insert_text_in_tag(document, "h5", "#")

    if starts_with(url, "https://git.sr.ht/~") then sourcehut.filter(document) end

    process_code_tags(document)

    local out = document:serialize()

    return out or html, false
end
table.insert(pre_format_html_hooks, pre_parse_html)

----------------------------------------------------------------------
--  Miscellaneous local functions, accessed with the Lua Console.
----------------------------------------------------------------------

-- Reload this file(hooks.lua) from within Links.
-- function reload()
--     dofile(hooks_file)
-- end

-- Helper local function.
-- function catto(output)
--     local doc = current_document_formatted(79)
--     if doc then writeto(output) write(doc) writeto() end
-- end

-- Email the current document, using Mutt(http://www.mutt.org).
-- This only works when called from lua_console_hook, below.
-- function mutt()
--     local tmp = tmpname()
--     writeto(tmp) write(current_document()) writeto()
--     table.insert(tmp_files, tmp)
--     return "run", "mutt -a "..tmp
-- end

-- Table of expressions which are recognised by our lua_console_hook.
console_hook_functions = {
    -- reload	= "reload()",
    -- mutt	= mutt,
}

function lua_console_hook(expr)
    local x = console_hook_functions[expr]
    if type(x) == "local function" then
        return x()
    else
        return "eval", x or expr
    end
end

----------------------------------------------------------------------
--  quit_hook
----------------------------------------------------------------------

-- We need to delete the temporary files that we create.
-- if not tmp_files then
--     tmp_files = {}
-- end
--
-- local function delete_tmp_files()
--     if tmp_files and os.remove then
--         tmp_files.n = nil
--         for i, v in tmp_files do os.remove(v) end
--     end
-- end
-- table.insert(quit_hooks, delete_tmp_files)

----------------------------------------------------------------------
--  Examples of keybinding
----------------------------------------------------------------------

-- Bind Ctrl-H to a "Home" page.

--    bind_key("main", "Ctrl-H",
--	      local function() return "goto_url", "http://www.google.com/" end)

-- Bind Alt-p to print.

--    bind_key("main", "Alt-p", lpr)

-- Bind Alt-m to toggle ALT="" mangling.

    -- bind_key("main", "Alt-m",
    --    function() mangle_blank_alt = not mangle_blank_alt end)

-- vim: shiftwidth=4 softtabstop=4
