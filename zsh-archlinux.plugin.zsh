#######################################
#               Pacman                #
#######################################

# Pacman - https://wiki.archlinux.org/title/Pacman/Tips_and_tricks

function pac() {
    case $1 in
    add)
    paru -S ${@:2}
    ;;
    remove)
    paru -Rs ${@:2}
    ;;
    upg)
    paru -Syu
    ;;
    upgrade)
    paru -Syu
    ;;
    list)
    if command -v fzf > /dev/null; then
    paru -Qq | fzf --preview 'paru -Qil {}' --layout=reverse --bind 'enter:execute(paru -Qil {} | less)'
    else
    paru -Qq | less
    fi
    ;;
    search)
    if [[ "$#" == 2 ]]; then
    if command -v fzf > /dev/null; then
    paru -Slq | grep $2 | fzf --preview 'paru -Si {}' --layout=reverse --bind 'enter:execute(paru -Si {} | less)'
    else
    paru -Slq | grep $2 | xargs paru -Si | less
    fi
    else
    if command -v fzf > /dev/null; then
    paru -Slq | fzf --preview 'paru -Si {}' --layout=reverse --bind 'enter:execute(paru -Si {} | less)'
    else
    paru -Slq | xargs paru -Si | less
    fi
    fi
    ;;
    prune)
    if paru -Qtdq > /dev/null; then
    paru -Rns $(paru -Qtdq)
    fi
    ;;
    own)
    paru -Qo ${@:2}
    ;;
    tree)
    if command -v pactree > /dev/null; then
    pactree ${@:2}
    else
    echo "Install `pacman-contrib` to use pactree(8)."
    fi
    ;;
    why)
    if command -v pactree > /dev/null; then
    pactree -r ${@:2}
    else
    echo "Install `pacman-contrib` to use pactree(8)."
    fi
    ;;
    clean)
    if command -v paccache > /dev/null; then
    paccache -r
    else
    echo "Install `pacman-contrib` to use paccache(8)."
    fi
    ;;
    esac
}

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `pac`. Otherwise, compinit will have already done that.
if [[ ! -f "${ZINIT[COMPLETIONS_DIR]:-$ZSH_CACHE_DIR/completions}/_pac" ]]; then
  typeset -g -A _comps
  autoload -Uz _pac
  _comps[pac]=_pac
fi

cat >| "${ZINIT[COMPLETIONS_DIR]:-$ZSH_CACHE_DIR/completions}/_pac" <<'EOF'
#compdef pac

# provides completions for installed packages
_pacman_completions_installed_packages() {
	local -a cmd packages packages_long
	packages_long=(/var/lib/pacman/local/*(/))
	packages=( ${${packages_long#/var/lib/pacman/local/}%-*-*} )
	compadd "$@" -a packages
}

local state com cur
local -a opts
local -a coms

cur=${words[${#words[@]}]}

# lookup for command
for word in ${words[@]:1}; do
    if [[ $word != -* ]]; then
        com=$word
        break
    fi
done

if [[ $cur == $com ]]; then
    state="command"
    coms+=("add:Installing packages." "remove:Removing packages." "upg:Upgrading packages." "list:List all the packages installed." "search:Search the package online." "prune:Removing unused packages (orphans)." "own:Which package a file in the file system belongs to." "tree:View the dependency tree of a package." "why:View the dependant tree of a package." "clean:Cleaning the package cache.")
fi

case $state in
(command)
    _describe 'command' coms
;;
*)
    case "$com" in
        (remove)
            _arguments '*:package:_pacman_completions_installed_packages'
        ;;
        (own)
            _arguments '*:file:_files'
        ;;
        (tree)
            _arguments '*:package:_pacman_completions_installed_packages'
        ;;
        (why)
            _arguments '*:package:_pacman_completions_installed_packages'
        ;;
        *)
        # fallback to file completion
            _arguments '*:file:_files'
        ;;
    esac
esac

EOF
