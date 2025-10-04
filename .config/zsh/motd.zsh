
if [ -f "/etc/os-release" ];then
    V_OS_NAME="$(cat /etc/os-release | grep ID | head -n1 | cut -d '=' -f2)"
    [ "$V_OS_NAME" = "alpine" ]&& echo -e "Welcome back $(whoami)\n"
    [ "$V_OS_NAME" = "arch" ] && ~/.dotfiles/bin/fetch
    [ "$V_OS_NAME" = "\"void\"" ] && ~/.dotfiles/bin/fetch
fi
