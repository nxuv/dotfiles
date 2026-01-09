Using ELinks with Lua
---------------------

Out of the box, ELinks with Lua will do nothing different from regular ELinks. You need to write some scripts.

### ELinks Lua additions

The Lua support is based on the idea of **hooks**. A hook is a function that gets called at a particular point during the execution of ELinks. To make ELinks do what you want, you can add and edit such hooks.

The Lua support also adds an extra dialog box, which you can open while in ELinks with the comma (`,`) key. Here you can enter Lua expressions for evaluation, or override it to do something different.

And finally, you can bind keystrokes to Lua functions. These keystrokes won't let you do any more than is possible with the Lua Console, but they're more convenient.

Note that this document assumes you have some knowledge of programming in Lua. For that, you should refer to the Lua reference manual ([http://www.lua.org/docs.html](http://www.lua.org/docs.html)). In fact, the language is relatively trivial, though. You could already do wonders with simply refactoring the example scripts.

### Config file

On startup, ELinks reads in two Lua scripts. Firstly, a system-wide configuration file called `/etc/elinks/hooks.lua`, then a file in your home directory called `~/.elinks/hooks.lua`. From these files, you can include other Lua files with `dofile`, if necessary.

To see what kind of things you should put in here, look at `contrib/lua/hooks.lua`.

### Hooks

The following hooks are available.

goto\_url\_hook (url, current\_url)

This hook is called when the user enters a string into the "Go to URL" dialog box. It is given the string entered, and the current URL (which may be `nil`). It should return a string, which is the URL that ELinks should follow, or `nil` to cancel the operation.

follow\_url\_hook (url)

This hook is passed the URL that ELinks is about to follow. It should return a string (the URL modified or unmodified), or `nil` to stop ELinks following the URL

pre\_format\_html\_hook (url, html)

This hook gets called just before the final time an HTML document is formatted, i.e. it only gets called once, after the entire document is downloaded. It will be passed the URL and HTML text as strings, and should return the modified HTML text, or `nil` if there were no modifications.

proxy\_for\_hook (url)

This hook is called when ELinks is about to load a resource from a URL. It should return "PROXY:PORT" (e.g. "localhost:8080") to use the specified proxy, "" to contact the origin server directly, or `nil` to use the default proxy of the protocol.

lua\_console\_hook (string)

This hook is passed the string that the user entered into the "Lua Console" dialog box. It should return two values: the type of action to take (`run`, `eval`, `goto-url` or `nil`), and a second argument, which is the shell command to run or the Lua expression to evaluate. Examples:

*   `return "run", "someprogram"` will attempt to run the program `someprogram`.
*   `return "eval", "somefunction(1+2)"` will attempt to call the Lua function `somefunction` with an argument, 3.
*   `return "goto_url", "http://www.bogus.com"` will ask ELinks to visit the URL "http://www.bogus.com".
*   `return nil` will do nothing.

quit\_hook ()

This hook is run just before ELinks quits. It is useful for cleaning up things, such as temporary files you have created.

### Functions

As well as providing hooks, ELinks provides some functions in addition to the standard Lua functions.

### Note

The standard Lua function `os.setlocale` affects ELinks' idea of the system locale, which ELinks uses for the "System" charset, for the "System" language, and for formatting dates. This may however have to be changed in a future version of ELinks, in order to properly support terminal-specific system locales.

current\_url ()

Returns the URL of the current page being shown (in the ELinks session that invoked the function).

current\_link ()

Returns the URL of the currently selected link, or `nil` if none is selected.

current\_title ()

Returns the title of the current page, or `nil` if none.

current\_document ()

Returns the current document as a string, unformatted.

current\_document\_formatted (\[width\])

Returns the current document, formatted for the specified screen width. If the width is not specified, then the document is formatted for the current screen width (i.e. what you see on screen). Note that this function does **not** guarantee all lines will be shorter than `width`, just as some lines may be wider than the screen when viewing documents online.

pipe\_read (command)

Executes `command` and reads in all the data from stdout, until there is no more. This is a hack, because for some reason the standard Lua function `file:read` seems to crash ELinks when used in pipe-reading mode.

execute (string)

Executes shell commands `string` without waiting for it to exit. Beware that you must not read or write to stdin and stdout. And unlike the standard Lua function `os.execute`, the return value is meaningless.

tmpname ()

Returns a unique name for a temporary file, or `nil` if no such name is available. The returned string includes the directory name. Unlike the standard Lua function `os.tmpname`, this one generates ELinks-related names (currently with "elinks" at the beginning of the name).

### Warning

The `tmpname` function does not create the file and does not guarantee exclusive access to it: the caller must handle the possibility that another process creates the file and begins using it while this function is returning. Failing to do this may expose you to symlink attacks by other users. To avoid the risk, use `io.tmpfile` instead; unfortunately, it does not tell you the name of the file.

bind\_key (keymap, keystroke, function)

Currently, `keymap` must be the string `"main"`. Keystroke is a keystroke as you would write it in the ELinks config file `~/.elinks/elinks.conf`. The function `function` should take no arguments, and should return the same values as `lua_console_hook`.

edit\_bookmark\_dialog (cat, name, url, function)

Displays a dialog for editing a bookmark, and returns without waiting for the user to close the dialog. The return value is `1` if successful, `nil` if arguments are invalid, or nothing at all if out of memory. The first three arguments must be strings, and the user can then edit them in input fields. There are also _OK_ and _Cancel_ buttons in the dialog. If the user presses _OK_, ELinks calls `function` with the three edited strings as arguments, and it should return similar values as in `lua_console_hook`.

xdialog (string \[, more strings…\], function)

Displays a generic dialog for editing multiple strings, and returns without waiting for the user to close the dialog. The return value is `1` if successful, `nil` if arguments are invalid, or nothing at all if out of memory. All arguments except the last one must be strings, and ELinks places them in input fields in the dialog. There can be at most 5 such strings. There are also _OK_ and _Cancel_ buttons in the dialog. If the user presses _OK_, ELinks calls `function` with the edited strings as arguments, and it should return similar values as in `lua_console_hook`.

set\_option (option, value)

Sets an ELinks option. The first argument `option` must be the name of the option as a string. ELinks then tries to convert the second argument `value` to match the type of the option. If successful, `set_option` returns `value`, else `nil`.

get\_option (option)

Returns the value of an ELinks option. The argument `option` must be the name of the option as a string. If the option does not exist, `get_option` returns `nil`.

\_ALERT (string)

Displays generic Lua error popup. Popups can be displayed on top of each other and will not stop Lua execution.

### Variables

elinks\_home

The name of the ELinks home directory, as a string. Typically this is the .elinks subdirectory of the user's home directory.

### User protocol

There is one more little thing which Links-Lua adds, which will not be described in detail here. It is the fake "user:" protocol, which can be used when writing your own addons. It allows you to generate web pages containing links to "user://blahblah", which can be intercepted by the `follow_url_hook` (among other things) to perform unusual actions. For a concrete example, see the bookmark addon.

