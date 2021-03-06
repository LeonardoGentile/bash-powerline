#!/usr/bin/env bash

__powerline() {

    ## standard fonts
    # ▷ ◣ ▶︎ ➤ 〉  $ % ⑂ + ⇡ ⇣
    ## for powerline patched fonts
    # █       

    # Max length of full path

    ## USER CONFIG ##
    readonly max_path_depth=3
    readonly MAX_PATH_LENGTH=30
    readonly PS_DELIM=''

    # FG_LRED='\[\e[91m\]'
    # FG_GRN='\[\e[32m\]'
    # FG_LBLU='\[\e[94m\]'
    # FG_WHT='\[\e[97m\]'

    # BG_LRED='\[\e[101m\]'
    # BG_GRN='\[\e[42m\]'
    # BG_LBLU='\[\e[104m\]'
    # BG_WHT='\[\e[107m\]'

    # RESET='\[\e[0m\]'
    # INVERT='\[\e[7m\]'
    # BOLD='\[\e[1m\]'

    # Unicode symbols
    readonly PS_SYMBOL_DARWIN=''
    readonly PS_SYMBOL_LINUX='$'
    readonly PS_SYMBOL_OTHER='%'

    readonly GIT_BRANCH_CHANGED_SYMBOL='+'
    # readonly GIT_BRANCH_CHANGED_SYMBOL='±'
    readonly GIT_NEED_PUSH_SYMBOL='⇡'
    readonly GIT_NEED_PULL_SYMBOL='⇣'


    # This is working for me, but I need to figure out
    # a good way to indicate whether we should use
    # powerline-fonts or not.
    if [[ $TERM = "xterm-16color" ]]; then
        # use standard fonts
        readonly PROMPT_DIVIDER=' '
        readonly PWD_DIVIDER='/'
        readonly GIT_BRANCH_SYMBOL=' ⑂ '

    else # use powerline-fonts
        readonly PROMPT_DIVIDER=''
        readonly PWD_DIVIDER='/'
        readonly GIT_BRANCH_SYMBOL='  '
    fi




    # Solarized colorscheme
    readonly FG_BASE03="\[$(tput setaf 8)\]"
    readonly FG_BASE02="\[$(tput setaf 0)\]"
    readonly FG_BASE01="\[$(tput setaf 10)\]"
    readonly FG_BASE00="\[$(tput setaf 11)\]"
    readonly FG_BASE0="\[$(tput setaf 12)\]"
    readonly FG_BASE1="\[$(tput setaf 14)\]"
    readonly FG_BASE2="\[$(tput setaf 7)\]"
    readonly FG_BASE3="\[$(tput setaf 15)\]"

    readonly BG_BASE03="\[$(tput setab 8)\]"
    readonly BG_BASE02="\[$(tput setab 0)\]"
    readonly BG_BASE01="\[$(tput setab 10)\]"
    readonly BG_BASE00="\[$(tput setab 11)\]"
    readonly BG_BASE0="\[$(tput setab 12)\]"
    readonly BG_BASE1="\[$(tput setab 14)\]"
    readonly BG_BASE2="\[$(tput setab 7)\]"
    readonly BG_BASE3="\[$(tput setab 15)\]"

    readonly FG_YELLOW="\[$(tput setaf 3)\]"
    readonly FG_ORANGE="\[$(tput setaf 9)\]"
    readonly FG_RED="\[$(tput setaf 1)\]"
    readonly FG_MAGENTA="\[$(tput setaf 5)\]"
    readonly FG_VIOLET="\[$(tput setaf 13)\]"
    readonly FG_BLUE="\[$(tput setaf 4)\]"
    readonly FG_CYAN="\[$(tput setaf 6)\]"
    readonly FG_GREEN="\[$(tput setaf 2)\]"

    readonly BG_YELLOW="\[$(tput setab 3)\]"
    readonly BG_ORANGE="\[$(tput setab 9)\]"
    readonly BG_RED="\[$(tput setab 1)\]"
    readonly BG_MAGENTA="\[$(tput setab 5)\]"
    readonly BG_VIOLET="\[$(tput setab 13)\]"
    readonly BG_BLUE="\[$(tput setab 4)\]"
    readonly BG_CYAN="\[$(tput setab 6)\]"
    readonly BG_GREEN="\[$(tput setab 2)\]"

    readonly DIM="\[$(tput dim)\]"
    readonly REVERSE="\[$(tput rev)\]"
    readonly RESET="\[$(tput sgr0)\]"
    readonly BOLD="\[$(tput bold)\]"

    # what OS?
    case "$(uname)" in
        Darwin)
            readonly PS_SYMBOL=$PS_SYMBOL_DARWIN
            ;;
        Linux)
            readonly PS_SYMBOL=$PS_SYMBOL_LINUX
            ;;
        *)
            readonly PS_SYMBOL=$PS_SYMBOL_OTHER
    esac


    __is_git_branch() {
        if (hash git &> /dev/null); then
          git rev-parse --is-inside-work-tree &> /dev/null
          return $?
        fi
      }


    __git_info() {
        if (__is_git_branch); then

        # [ -x "$(which git)" ] || return    # git not found
        # # local git_eng="env LANG=C git"   # force git output in English to make our work easier

            local git="env git"

            # get current branch name or short SHA1 hash for detached head
            local branch="$($git symbolic-ref --short HEAD 2>/dev/null || $git describe --tags --always 2>/dev/null)"
            [ -n "$branch" ] || return  # git branch not found

            local marks

            # branch is modified?
            [ -n "$($git status --porcelain 2>/dev/null)" ] && marks+=" $GIT_BRANCH_CHANGED_SYMBOL"

            # how many commits local branch is ahead/behind of remote?
            local stat="$($git status --porcelain --branch 2>/dev/null | grep '^##' | grep -o '\[.\+\]$')"
            local aheadN="$(echo $stat | grep -o 'ahead [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
            local behindN="$(echo $stat | grep -o 'behind [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
            [ -n "$aheadN" ] && marks+=" $GIT_NEED_PUSH_SYMBOL$aheadN"
            [ -n "$behindN" ] && marks+=" $GIT_NEED_PULL_SYMBOL$behindN"

            # print the git branch segment without a trailing newline
            printf "${GIT_BRANCH_SYMBOL}${branch}${marks} "
        fi
    }

    __virtualenv() {
        # Copied from Python virtualenv's activate.sh script.
        # https://github.com/pypa/virtualenv/blob/a9b4e673559a5beb24bac1a8fb81446dd84ec6ed/virtualenv_embedded/activate.sh#L62
        # License: MIT
        if [ "x$VIRTUAL_ENV" != "x" ]; then
            if [ "`basename \"$VIRTUAL_ENV\"`" == "__" ]; then
                # special case for Aspen magic directories
                # see http://www.zetadev.com/software/aspen/
                printf "[`basename \`dirname \"$VIRTUAL_ENV\"\``]"
            else
                printf "(`basename \"$VIRTUAL_ENV\"`)"
            fi
        fi
    }

    # __pwd() {
    #     # Use ~ to represent $HOME prefix
    #     local pwd=$(pwd | sed -e "s|^$HOME|~|")
    #     if [[ ( $pwd = ~\/*\/* || $pwd = \/*\/*/* ) && ${#pwd} > $MAX_PATH_LENGTH ]]; then
    #         local IFS='/'
    #         read -ra split <<< "$pwd"
    #         if [[ $pwd = ~* ]]; then
    #             pwd="~/.../${split[-1]}"
    #         else
    #             pwd="/${split[1]}/.../${split[-1]}"
    #         fi
    #     fi
    #     printf "$pwd"
    # }

    __getpwd() {
        local my_pwd=$(pwd)

        # substitude ~ for $HOME
        local my_pwd=$(sed -e "s|^$HOME|~|" <<< $my_pwd)

        # get an array of directories
        # local split=(${my_pwd//\// })
        # ???
        local oIFS=$IFS
        local IFS='/'
        read -ra split <<< "$my_pwd"
        IFS=$oIFS

        # count how many backslashes
        local pathDepth=${#split[@]}

        # calculate index of last element
        lastPosition=$((pathDepth-1))

        # Substitude '  ' for instances of '/'
        my_pwd=$(sed -e "s|/|  |g" <<< $my_pwd)

        if [[ $my_pwd = ~* ]]; then
          # shorten path if more than 2 directories lower than home
          if [[ $pathDepth > $max_path_depth ]]; then
            my_pwd="~  ...  ${split[lastPosition]}"
          fi
        else
          # In other than home, shorten path when greater than 3
          # directories deep.
          if [[ $pathDepth > $max_path_depth ]]; then
            my_pwd="/  ${split[1]}   ...   ${split[lastPosition]}"
          else
            # append a backslash to the front of pwd
            my_pwd=$(sed -e "s|^|\/ |" <<< $my_pwd)
          fi
        fi
        echo -n "$my_pwd"
      }


    ps1() {
    #     # Check the exit code of the previous command and display different
    #     # colors in the prompt accordingly.
    #     if [ $? -eq 0 ]; then
    #         local BG_EXIT="$BG_GREEN"
    #     else
    #         local BG_EXIT="$BG_RED"
    #     fi

    #     PS1=""
    #     PS1+="$BG_BASE0$FG_BASE3$(__virtualenv)$RESET"
    #     # PS1+="$BG_BASE1$FG_BASE3 $(__pwd) $RESET"
    #     # path
    #     PS1+="$BG_BASE0$FG_BASE3 $(__getpwd) $RESET_COLORS"
    #     PS1+="$BG_BLUE$FG_BASE3\$(__git_info)$RESET"
    #     PS1+="$BG_EXIT$FG_BASE3 $PS_SYMBOL $RESET "
    # }

    # PROMPT_COMMAND=ps1

    # Check the exit code of the previous command and display different
    # colors in the prompt accordingly.
    if [ $? -ne 0 ]; then
      local BG_EXIT="$BG_RED"
      local FG_EXIT="$FG_RED"
    else
      local BG_EXIT="$BG_GREEN"
      local FG_EXIT="$FG_GREEN"
    fi

    PS1=""

    # username
    if [[ $(whoami) == "root" ]]; then
      PS1+="$BG_RED$FG_BASE3 \u $RESET"
      PS1+="$BG_BASE0$FG_RED$PROMPT_DIVIDER$RESET"
    else
      PS1+="$BG_BLUE$FG_BASE3 \u $RESET"
      PS1+="$BG_BASE00$FG_BLUE$PROMPT_DIVIDER$RESET"
    fi

    PS1+="$BG_BASE0$FG_BASE3$(__virtualenv)$RESET"

    # path
    # PS1+="$BG_BASE00$FG_BASE3 $(__getpwd) $RESET"
    PS1+="$BG_BASE0$FG_BASE3 $(__getpwd) $RESET"

    # git status
    if (__is_git_branch); then
      PS1+="$BG_BASE01$FG_BASE00$PROMPT_DIVIDER$RESET"
      PS1+="$BG_BASE01$FG_BASE1 $(__git_info) $RESET"
      PS1+="$BG_EXIT$FG_BASE01$PROMPT_DIVIDER$RESET"
    else
      PS1+="$BG_EXIT$FG_BASE00$PROMPT_DIVIDER$RESET"
    fi
    # segment transition
    PS1+="$FG_EXIT$PROMPT_DIVIDER$RESET "
  }

  PROMPT_COMMAND=ps1
}

__powerline
unset __powerline