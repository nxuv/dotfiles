---@diagnostic disable: unused-vararg, deprecated, unused-local, unused-function, lowercase-global, undefined-global, param-type-mismatch, cast-local-type, undefined-field, need-check-nil

--[[
Known stuffs
http://elinks.or.cz/documentation/html/manual.html-chunked/ch14s03.html
https://github.com/rkd77/elinks/blob/master/contrib/lua/hooks.lua.in

goto_url_hook
follow_url_hook
pre_format_html_hook
proxy_for_hook
lua_console_hook

_ALERT
current_url
current_link
current_title
current_document
current_document_formatted
pipe_read
execute
tmpname
bind_key
edit_bookmark_dialog
xdialog
set_option
get_option
reload
goto_url
elinks_home
]]

-- local htmlparser = loadfile(elinks_home .. "htmlparser/init.lua")()
-- local htmlsyntax = loadfile(elinks_home .. "syntaxhighlight/init.lua")()

-- ./?.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;/usr/lib/lua/5.1/?.lua;/usr/lib/lua/5.1/?/init.lua
-- print(package.path)
package.path = package.path .. ";" ..
    elinks_home .. "?.lua;" ..
    elinks_home .. "syntaxhighlight/?.lua;"

local htmlparser = require("gumbo")
-- https://github.com/orbitalquark/scintillua/tree/default/lexers
local htmlsyntax = require("syntaxhighlight")

-- local ih = htmlsyntax.highlight_to_html("lua", "local function() end")
-- local el = htmlparser.parse(ih)
-- local al = el:select("pre")

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

follow_url_hooks = {n=0}
function follow_url_hook(url)
    for i, fn in ipairs(follow_url_hooks) do
        local new, stop = fn(url)
        url = new
    end

    return url
end

quit_hooks = {n=0}
function quit_hook(url, html)
    for i, fn in ipairs(quit_hooks) do
        fn()
    end
end

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

function starts_with(url, prefix)
    return string.sub(url, 1, string.len (prefix)) == prefix
end

local function bang_search(url)
    if url == nil then return nil, nil end

    if url:sub(1, 1) == "!" then
        return "https://surf.sily.dev/?q=" .. url
    end

    return url
end
table.insert(goto_url_hooks, bang_search)

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

local function remove_class(document, class_name)
    local elements = document:getElementsByClassName(class_name)
    for _, element in ipairs(elements) do element:remove() end
end

local function remove_tags(document, tag_name)
    local elements = document:getElementsByTagName(tag_name)
    for _, element in ipairs(elements) do element:remove() end
end

local function remove_id(document, id_name)
    document:getElementById(id_name):remove()
end

-- for node in document.body:walk() do
--     if node.localName == "meta" then end
-- end

local function replace_attribute_if(node, attr, if_value, replace_value)
    if node:getAttribute(attr) == if_value then
        node:setAttribute(attr, replace_value)
    end
end

local function insert_hr_before_class(document, classname)
    local elements = document:getElementsByClassName(classname)
    for _, element in ipairs(elements) do
        element.parentNode:insertBefore(document:createElement("hr"), element)
    end
end

local function insert_hr_after_class(document, classname)
    local elements = document:getElementsByClassName(classname)
    for _, element in ipairs(elements) do
        element.parentNode:insertBefore(document:createElement("hr"), element.nextSibling)
    end
end

local function insert_hr_before_tag(document, tag)
    local elements = document:getElementsByTagName(tag)
    for _, element in ipairs(elements) do
        element.parentNode:insertBefore(document:createElement("hr"), element)
    end
end

local function insert_hr_after_tag(document, tag)
    local elements = document:getElementsByTagName(tag)
    for _, element in ipairs(elements) do
        element.parentNode:insertBefore(document:createElement("hr"), element.nextSibling)
    end
end

local function insert_text_in_tag(document, tag, text)
    local elements = document:getElementsByTagName(tag)
    for _, element in ipairs(elements) do
        if #element.children > 0 then
            element:insertBefore(document:createTextNode(text), element.firstElementChild)
        else
            element.textContent = text .. element.textContent
        end
    end
end

local function sourcehut_filter(document)
    remove_class(document, "icon")
    remove_class(document, "navbar-nav")

    -- local blob = document:getElementsByClassName("blob")[1]
    -- blob.parentNode:insertBefore(document:createElement("hr"), blob)

    insert_hr_before_class(document, "header-extension")

    local code_views = document:getElementsByClassName("code-viewport")
    for _, code in ipairs(code_views) do
        remove_class(document, "lines")
    end
    local highlights = document:getElementsByClassName("highlight")
    for _, highlight in ipairs(highlights) do
        if highlight.tagName == "DIV" then
            for node in highlight:walk() do
                if node.tagName == "SPAN" then
                    replace_attribute_if(node, "class", "c" , "token_comment")
                    replace_attribute_if(node, "class", "c1", "token_comment")
                    replace_attribute_if(node, "class", "ch", "token_comment")
                    replace_attribute_if(node, "class", "cm", "token_comment")
                    replace_attribute_if(node, "class", "cp", "token_comment")
                    replace_attribute_if(node, "class", "cpf", "token_comment")
                    replace_attribute_if(node, "class", "cs", "token_comment")

                    replace_attribute_if(node, "class", "k" , "token_keyword")
                    replace_attribute_if(node, "class", "kc", "token_keyword")
                    replace_attribute_if(node, "class", "kd", "token_keyword")
                    replace_attribute_if(node, "class", "kp", "token_keyword")
                    replace_attribute_if(node, "class", "kr", "token_keyword")
                    replace_attribute_if(node, "class", "kt", "token_keyword")
                    replace_attribute_if(node, "class", "kn", "token_keyword")
                    replace_attribute_if(node, "class", "no", "token_keyword")

                    replace_attribute_if(node, "class", "gu", "token_number")
                    replace_attribute_if(node, "class", "il", "token_number")
                    replace_attribute_if(node, "class", "l" , "token_number")
                    replace_attribute_if(node, "class", "m" , "token_number")
                    replace_attribute_if(node, "class", "mb", "token_number")
                    replace_attribute_if(node, "class", "mf", "token_number")
                    replace_attribute_if(node, "class", "mh", "token_number")
                    replace_attribute_if(node, "class", "mi", "token_number")
                    replace_attribute_if(node, "class", "mo", "token_number")
                    replace_attribute_if(node, "class", "se", "token_number")

                    replace_attribute_if(node, "class", "na",  "token_special")
                    replace_attribute_if(node, "class", "nc",  "token_special")
                    replace_attribute_if(node, "class", "nd",  "token_special")
                    replace_attribute_if(node, "class", "ne",  "token_special")
                    replace_attribute_if(node, "class", "nf",  "token_special")

                    replace_attribute_if(node, "class", "dl",  "token_string")
                    replace_attribute_if(node, "class", "ld",  "token_string")
                    replace_attribute_if(node, "class", "s" ,  "token_string")
                    replace_attribute_if(node, "class", "s1",  "token_string")
                    replace_attribute_if(node, "class", "s2",  "token_string")
                    replace_attribute_if(node, "class", "sa",  "token_string")
                    replace_attribute_if(node, "class", "sb",  "token_string")
                    replace_attribute_if(node, "class", "sc",  "token_string")
                    replace_attribute_if(node, "class", "sd",  "token_string")
                    replace_attribute_if(node, "class", "sh",  "token_string")
                    replace_attribute_if(node, "class", "si",  "token_string")
                    replace_attribute_if(node, "class", "sr",  "token_string")
                    replace_attribute_if(node, "class", "ss",  "token_string")
                    replace_attribute_if(node, "class", "sx",  "token_string")

                    -- replace_attribute_if(node, "class", "nx", "token_identifier")
                    -- replace_attribute_if(node, "class", "o",  "token_operator")
                    -- replace_attribute_if(node, "class", "p",  "token_parens")
                end
            end
        end
    end
end

local function process_code_tags(document)
    local pres = document:getElementsByTagName("pre")
    for _, pre in ipairs(pres) do
        local data_language = pre:getAttribute("data-language")
        if data_language then
            local code, err = htmlsyntax.highlight_to_html(
                data_language,
                pre.innerHTML,
                { class_prefix = "token_" }
            )
            if err then _ALERT(err) else
                local element = htmlparser.parse(code, { contextElement = "pre" })
                local e = element.documentElement.childNodes[1]
                e:removeAttribute("class")
                e:setAttribute("data-language", data_language)
                pre.parentNode:replaceChild(e, pre)
            end
        end
    end
    local codes = document:getElementsByTagName("code")
    for _, code in ipairs(codes) do
        local e = document:createElement("span")
        e.textContent = "["
        code.parentNode:insertBefore(e, code)
        e = document:createElement("span")
        e.textContent = "]"
        code.parentNode:insertBefore(e, code.nextSibling)
    end
end

local function pre_parse_html(url, html)
    local document = htmlparser.parse(html)
    local head = document.head

    remove_tags(head, "link")
    remove_tags(document, "style")
    remove_tags(document, "script")
    remove_tags(document, "template")

    insert_hr_after_tag(document, "h1")
    -- insert_hr_after_tag(document, "h2")
    -- insert_hr_after_tag(document, "h3")

    -- insert_text_in_tag(document, "h1", "#")
    -- insert_text_in_tag(document, "h2", "#")
    -- insert_text_in_tag(document, "h3", "#")
    -- insert_text_in_tag(document, "h4", "#")
    -- insert_text_in_tag(document, "h5", "#")

    if starts_with(url, "https://git.sr.ht/~") then sourcehut_filter(document) end

    process_code_tags(document)

    local out = document:serialize()

    return out or html, false

    -- return htmlsyntax.highlight_to_html(
    --     "lua",
    --     [[function main(thing) return 12 .. "asdf" .. true end]],
    --     { class_prefix = "token_", bare = true }
    -- ), false
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
