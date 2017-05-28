# Promt ########################################################################

# http://www.utf8icons.com/
# http://apps.timwhitlock.info/emoji/tables/unicode

autoload +X -U colors && colors

################
### PROMPT SETUP
################

setopt notify # Report the status of background jobs immediately, rather than waiting until just before printing a prompt.
setopt interactive_comments # Allowes to use #-sign as comment within commandline
setopt prompt_subst # substitude variables within prompt string

_prompt_cli_id=0
# increment before prompt
function _prompt_cli_id_increment { ((_prompt_cli_id++)) }
precmd_functions=(_prompt_cli_id_increment $precmd_functions)

_prompt_exec_id=0
# increment before execute command
function _prompt_exec_id_increment { ((_prompt_exec_id++)) }
preexec_functions=(_prompt_exec_id_increment $preexec_functions)

###### Command Line ############################################################

function _prompt_info {

  # prompt_info indicator
  local prompt_info="${fg_bold[grey]}#${reset_color} "

  # current_user & current_host
  local current_user="$USER" # "$(whoami)"
  local current_host="$HOST" # "$(hostname -s)"
  if [ "$current_user" = "root" ]; then
    prompt_info+="${fg_bold[red]}"
  else
    prompt_info+="${fg[cyan]}"
  fi
  prompt_info+="$current_user${reset_color}${fg_bold[grey]}@${reset_color}${fg[blue]}$current_host${reset_color}"

  # current_dir
  local current_dir="$(echo $PWD | sed -e "s|^$HOME|~|" -e 's|\([^~/.]\)[^/]*/|\1/|g')"
  prompt_info+=" ${fg_bold[grey]}in${reset_color} ${fg[yellow]}$current_dir${reset_color}"

  # current_branch
  #git status | head -1 | sed 's|On branch ||' | sed 's|HEAD detached at ||'
  local current_branch_status_line="$(git status --short --branch --porcelain 2>/dev/null | head -1)"
  if [ -n "$current_branch_status_line" ]; then
    if [[ "$current_branch_status_line" == *"(no branch)"* ]]; then
        prompt_info+=" ${fg_bold[grey]}at${reset_color} ${fg[green]}detached HEAD${reset_color}"
    else
        local branch_name="$current_branch_status_line" && branch_name="${branch_name#* }" && branch_name="${branch_name%%...*}"
        prompt_info+=" ${fg_bold[grey]}on${reset_color} ${fg[green]}${branch_name}$current_branch${reset_color}"
    fi

    if [ -n "$( git status --short --porcelain 2>/dev/null | head -1)" ]; then
      prompt_info+="${fg_bold[magenta]}*${reset_color}"
    fi
  fi

  echo "$prompt_info"
}

### prompt
precmd_functions=($precmd_functions _prompt_info)
PS1='❯ '
PS2='▪ '

### alternative approach
# PS1=$'$(_prompt_info)\n❯ '
# PS2=$'▪ '

# right prompt
# RPROMPT='[%D{%H:%M:%S}]' # date


###### EXIT CODE ###############################################################
# print exit code on error
_prompt_exit_code_exec_id=0
function _prompt_exit_code {
  local exit_code=$?
  if [ $exit_code != 0 ] && [ $_prompt_exec_id != $_prompt_exit_code_exec_id ]; then
    echo "${fg_bold[red]}✖ $exit_code${reset_color}"
  fi
  _prompt_exit_code_exec_id=$_prompt_exec_id
}
# run before prompt
precmd_functions=(_prompt_exit_code $precmd_functions)


###### REZIZE TERMINAL WINDOW ##################################################
# Ensure that the prompt is redrawn when the terminal size changes.
function TRAPWINCH {
  if [ $_prompt_cli_id -gt 1 ]; then # prevent segmentation fault
    zle && zle reset-prompt && zle -R
  fi
}

################
### PROMPT UTILS
################

# Edit the current command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

function divider { # print online of divider icons
  local dividerIcon="▪"   # ≡ ▪ ◊ ◄►
  local dividerSpaces="$(echo $dividerIcon | sed 's|.| |g')"

  #zle clear-screen
  printf '\e[0K\r\e[0K\r%*s' "$((${COLUMNS:-$(tput cols)} - 2))" '' | sed "s|$dividerSpaces|$dividerIcon|g"
}

function _divider_widget { # print online of divider icons
  divider
  echo ''
  zle reset-prompt
}
zle -N _divider_widget
bindkey "^N" _divider_widget

function _clear_screen_widget { # clear screen without coping last line
  printf '\e[0K\r\e[0K\r'
  zle clear-screen
}
zle -N _clear_screen_widget
bindkey "^L" _clear_screen_widget
