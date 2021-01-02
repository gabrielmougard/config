function fish_greeting -d "Greeting message on shell session start up"
    echo ""
    echo -en "        |         "(welcome_message) "\n"
    echo -en "       / \        \n"
    echo -en "      / _ \       "(show_date_info) "\n"
    echo -en "     |.o '.|      \n"
    echo -en "     |'._.'|      Space vessel computer:\n"
    echo -en "     |     |      " (show_os_info) "\n"
    echo -en "   ,'|  |  |`.    " (show_cpu_info) "\n"
    echo -en "  /  |  |  |  \   " (show_mem_info) "\n"
    echo -en "  |,-'--|--'-.|   " (show_net_info) "\n"
    echo ""
    set_color grey
    set_color normal
end


function welcome_message -d "Say welcome to user"
    echo -en "Welcome, "
    set_color FFF  # white
    echo -en (scutil --get LocalHostName) "!"
    set_color normal
end


function show_date_info -d "Prints information about date"

    set --local up_time (uptime | cut -d "," -f1 | cut -d "p" -f2 | sed 's/^ *//g')

    set --local time (echo $up_time | cut -d " " -f2)
    set --local formatted_uptime $time

    switch $time
    case "days" "day"
        set formatted_uptime "$up_time"
    case "min"
        set formatted_uptime $up_time"utes"
    case '*'
        set formatted_uptime "$formatted_uptime hours"
    end

    echo -en "Today is "
    set_color cyan
    echo -en (date +%Y.%m.%d)
    set_color normal
    echo -en ", we are up and running for "
    set_color cyan
    echo -en "$formatted_uptime"
    set_color normal
    echo -en "."
end


function show_os_info -d "Prints operating system info"

    set_color yellow
    echo -en "\tOS: "
    set_color 0F0  # green
    echo -en (uname -sm)
    set_color normal
end


function show_cpu_info -d "Prints iformation about cpu"

    set --local os_type (uname -s)
    set --local cpu_info ""

    if [ "$os_type" = "Linux" ]

        set --local procs_n (grep -c "^processor" /proc/cpuinfo)
        set --local cores_n (grep "cpu cores" /proc/cpuinfo | head -1 | cut -d ":"  -f2 | tr -d " ")
        set --local cpu_type (grep "model name" /proc/cpuinfo | head -1 | cut -d ":" -f2)
        set cpu_info "$procs_n processors, $cores_n cores, $cpu_type"

    else if [ "$os_type" = "Darwin" ]

        set --local procs_n (system_profiler SPHardwareDataType | grep "Number of Processors" | cut -d ":" -f2 | tr -d " ")
        set --local cores_n (system_profiler SPHardwareDataType | grep "Cores" | cut -d ":" -f2 | tr -d " ")
        set --local cpu_type (system_profiler SPHardwareDataType | grep "Processor Name" | cut -d ":" -f2 | tr -d " ")
        set cpu_info "$procs_n processors, $cores_n cores, $cpu_type"
    end

    set_color yellow
    echo -en "\tCPU: "
    set_color 0F0  # green
    echo -en $cpu_info
    set_color normal
end


function show_mem_info -d "Prints memory information"

    set --local os_type (uname -s)
    set --local total_memory ""

    if [ "$os_type" = "Linux" ]
        set total_memory (free -h | grep "Mem" | cut -d " " -f 11)

    else if [ "$os_type" = "Darwin" ]
        set total_memory (system_profiler SPHardwareDataType | grep "Memory:" | cut -d ":" -f 2 | tr -d " ")
    end

    set_color yellow
    echo -en "\tMemory: "
    set_color 0F0  # green
    echo -en $total_memory
    set_color normal
end


function show_net_info -d "Prints information about network"

    set --local os_type (uname -s)
    set --local ip ""
    set --local gw ""

    if [ "$os_type" = "Linux" ]
        set ip (ip address show | grep -E "inet .* brd .* dynamic" | cut -d " " -f6)
        set gw (ip route | grep default | cut -d " " -f3)

    else if [ "$os_type" = "Darwin" ]
        set ip (ifconfig | grep -v "127.0.0.1" | grep "inet " | head -1 | cut -d " " -f2)
        set gw (netstat -nr | grep -E "default.*UGSc" | cut -d " " -f13)
    end

    set_color yellow
    echo -en "\tNet: "
    set_color 0F0  # green
    echo -en "Ip address $ip, default gateway $gw"
    set_color normal
end

# Fish git prompt
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'none'
set -g fish_prompt_pwd_dir_length 3

# colored man output
# from http://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
setenv LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
setenv LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
setenv LESS_TERMCAP_me \e'[0m'           # end mode
setenv LESS_TERMCAP_se \e'[0m'           # end standout-mode
setenv LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
setenv LESS_TERMCAP_ue \e'[0m'           # end underline
setenv LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

setenv FZF_DEFAULT_COMMAND 'fd --type file --follow'
setenv FZF_CTRL_T_COMMAND 'fd --type file --follow'
setenv FZF_DEFAULT_OPTS '--height 20%'

# Some alias to use more modern commands
function l --wraps exa
    exa $argv
end

function ls --wraps exa
    exa $argv
end

# activate tmux by default
if status --is-interactive
	tmux ^ /dev/null; and exec true
end
