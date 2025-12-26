if [ -f "/etc/os-release" ];then
    sleep 0.1
    V_OS_NAME="$(cat /etc/os-release | grep ID | head -n1 | cut -d '=' -f2)"
    [ "$V_OS_NAME" = "alpine" ]&& echo -e "Welcome back $(whoami)\n"
    [ "$V_OS_NAME" = "arch" ] && fetch
    [ "$V_OS_NAME" = "\"void\"" ] && fetch
fi

if __has $HOME/.dot/unbin/t.py; then
    __T_VAL="$(t)"
    if [ "$__T_VAL" != "" ]; then
        # __T_SEP="─"
        # __T_GREET="You have $(echo "$__T_VAL" | wc -l) tasks pending"
        # __T_LEN=$(echo "$(echo "$__T_VAL" | sed 's/^/  /')\n$__T_GREET" | wc -L)
        # let __T_LEN--
        # printf "$__T_SEP%.0s" {0..$__T_LEN}; echo ''
        # echo "$__T_GREET"
        # echo "$(echo "$__T_VAL" | sed 's/^/  /')"
        # printf "$__T_SEP%.0s" {0..$__T_LEN}; echo ''
        # echo ''
        # echo ''
        printf "You "
        echo -e "have $(echo "$__T_VAL" | wc -l) tasks pending"
        echo -e "$(echo "$__T_VAL" | sed 's/^/  /')"
        echo ''
    fi
fi
