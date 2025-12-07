[ -n "$ZSH_HOOKS_DONE" ] && return 0

export ZSH_HOOKS_DONE="yes"

__on_pwd_chage() {
    if [ -d .git ]; then
        __has onefetch && gitshort || git status
        echo ""
    fi
    ls
}

__starship_prompt_builder() {
    # hr "─"
    export JOB_COUNT=$( jobs | wc -l )
    [ ! -n "$(jobs)" ] && export JOB_COUNT=0

    if jobs | grep -q nvim ; then
        export STARSHIP_SHOW_NVIM=true
    else
        export STARSHIP_SHOW_NVIM=false
    fi

    if ( [ $STARSHIP_SHOW_NVIM = false ] && [ $JOB_COUNT -gt 0 ] ) || ( [ $STARSHIP_SHOW_NVIM = true ] && [ $JOB_COUNT -gt 1 ] ); then
        export STARSHIP_SHOW_JOBS=true
    else
        export STARSHIP_SHOW_JOBS=false
    fi
}

# ZSH's history is different from bash,
# so here's my fucntion to remove
# the last item from history.
__remove_last_history_entry() {
    # This sub-checks if [ the argument passed is a number.() { ]; then
    # Thanks to @yabt on stackoverflow for this :).
    is_int() ( return $(test "$@" -eq "$@" > /dev/null 2>&1); )

    # Set history file's location
    history_file="$HISTFILE"
    history_temp_file="${history_file}.tmp"
    line_cout=$(wc -l $history_file)

    # Check if [ the user passed a number, ]; then
    # so we can delete x lines from history.
    lines_to_remove=1
    if [ $# -eq 0 ]; then
        # No arguments supplied, so set to one.
        lines_to_remove=1
    else
        # An argument passed. Check if [ it's a number. ]; then
        if [ $(is_int "${1}") ]; then
            lines_to_remove="$1"
        else
            echo "Unknown argument passed. Exiting..."
            return
        fi
    fi

    # Make the number negative, since head -n needs to be negative.
    lines_to_remove="-${lines_to_remove}"

    fc -W # write current shell's history to the history file.

    # Get the files contents minus the last entry(head -n -1 does that)
    #cat $history_file | head -n -1 &> $history_temp_file
    cat $history_file | head -n "${lines_to_remove}" &> $history_temp_file
    mv -f "$history_temp_file" "$history_file"

    fc -R # read history file.
}

COMMAND_IGNORE="fg\s*.*|bg\s*.*|jobs\s*.*|history\s*.*"

__zsh_history_delete() {
    LAST_HIST=$( fc -l -1 | sed -E "s/ +[0-9]+ +//" )
    if [[ "$LAST_HIST" =~ "$COMMAND_IGNORE" ]]; then
        __remove_last_history_entry
    fi
}

chpwd_functions+=("__on_pwd_chage")
precmd_functions+=("__starship_prompt_builder")
precmd_functions+=("__zsh_history_delete")

__fix_cursor() {
   echo -ne '\e[5 q'
}

precmd_functions+=("__fix_cursor")


