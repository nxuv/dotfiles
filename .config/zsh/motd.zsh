if [ -f "/etc/os-release" ];then
    sleep 0.1
    V_OS_NAME="$(cat /etc/os-release | grep ID | head -n1 | cut -d '=' -f2)"
    [ "$V_OS_NAME" = "alpine" ] && echo -e "Welcome back $(whoami)\n"
    [ "$V_OS_NAME" = "arch" ] && fetch
    [ "$V_OS_NAME" = "\"void\"" ] && fetch
fi

if __has $HOME/.dot/unbin/t.py; then
    __T_VAL="$(t)"
    if [ "$__T_VAL" != "" ]; then
        printf "You "
        echo -e "have $(echo "$__T_VAL" | wc -l) tasks pending"
        echo -e "$(echo "$__T_VAL" | sed 's/^/  /')"
        echo ''
    fi
fi
