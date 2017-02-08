SELF_DIR="${0:A:h}"

#### load zprofile plugin [lazy]
source "$SELF_DIR/plugins/zprofile.zsh"
if zprofile::active; then zprofile::before; fi

#### load zgem extension manager
# export ZGEM_VERBOSE='true'
source "$SELF_DIR/plugins/zgem.zsh"

source "$SELF_DIR/plugins/async.zsh";

zgem add "$SELF_DIR/modules/general.zsh"

zgem add "$SELF_DIR/modules/history.zsh"

zgem add "$SELF_DIR/modules/prompt.zsh"

zgem add "$SELF_DIR/modules/alias.zsh"

zgem add 'https://github.com/zsh-users/zsh-syntax-highlighting.git' from:'git' use:'zsh-syntax-highlighting.zsh'
zgem add 'https://github.com/zsh-users/zsh-history-substring-search.git' from:'git' use:'zsh-history-substring-search.zsh'
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=default,fg=magenta,bold'
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=default,fg=black,bold'
  HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'
  bindkey '^[[A' history-substring-search-up     # bind arrow-up
  bindkey '^[[B' history-substring-search-down   # bind arrow-down

async zgem add 'https://github.com/zsh-users/zsh-completions.git' from:'git' use:'zsh-completions.plugin.zsh'
async zgem add 'https://raw.githubusercontent.com/docker/docker/master/contrib/completion/zsh/_docker' from:'http' as:'completion'
async zgem add 'https://raw.githubusercontent.com/docker/compose/master/contrib/completion/zsh/_docker-compose' from:'http' as:'completion'
async zgem add "$SELF_DIR/modules/completion.zsh"
async "autoload +X -U compinit && compinit"

async zgem add 'https://github.com/rupa/z.git' from:'git' use:'z.sh'

async zgem add "$SELF_DIR/utils/which.zsh"
async zgem add "$SELF_DIR/utils/man.zsh"
async zgem add "$SELF_DIR/utils/diff.zsh"
async zgem add "$SELF_DIR/utils/find.zsh"
async zgem add "$SELF_DIR/utils/network.zsh"
async zgem add "$SELF_DIR/utils/process.zsh"
async zgem add "$SELF_DIR/utils/ssh.zsh"
async zgem add "$SELF_DIR/utils/sudo.zsh"
async zgem add "$SELF_DIR/utils/git.zsh"
async zgem add "$SELF_DIR/utils/docker.zsh"

async zgem add "$SELF_DIR/utils/http-server.zsh"
async zgem add "$SELF_DIR/utils/maven.zsh"

async zgem add "$SELF_DIR/utils/osx.zsh"
async zgem add "$SELF_DIR/utils/pane.zsh"

if zprofile::active; then zprofile::after; fi

############## zconfig util function

function zconfig {
  local cmd="$1"
  shift

  case "$cmd" in
    '');& 'edit')
      _zconfig::edit $@
      ;;
    'update')
      _zconfig::update
      ;;
    'upgrade')
      _zconfig::update
      zgem update
      ;;
    'reload')
      _zconfig::reload
      ;;
    'profile')
      zprofile $@
      ;;
    *)
      echo "${fg_bold[red]}[zconfig]${reset_color}" "Unknown command '$cmd'" >&2
      echo "${fg_bold[red]}[zconfig]${reset_color}" "Protocol: {edit|update|upgrade|reload|profile}" >&2
      return 1
      ;;
  esac
}

function _zconfig::edit {
  local editor=${1:-$EDITOR}
  $editor "$SELF_DIR"
}

function _zconfig::update {
  echo "${fg_bold[blue]}[zconfig]${reset_color}" "${fg_bold[blue]}home directory${reset_color} $SELF_DIR"
  (cd $SELF_DIR; git pull)
}

function _zconfig::reload {
  exec "$SHELL" -l
}