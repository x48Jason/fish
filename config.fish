set fish_greeting ""

set -gx PATH $HOME/nvim-linux64/bin $HOME/bin $PATH

if ! status is-interactive
	exit 0
end

set -gx TERM xterm-256color
set -gx TIG_SCRIPT ~/bin/tig-init.script

# Commands to run in interactive sessions can go here
set fish_color_search_match --background=green
set fish_color_error ff9e64
set fish_color_normal 2ac3de # blue
# set fish_color_command 9ece6a # green
set fish_color_command 2ac3de # blue
set fish_color_valid_path green
set fish_color_autosuggestion 565f89

set -g theme_display_user no
set -g theme_hostname always

set -gx EDITOR nvim

if type -q exa
  alias ll "exa -l -g --icons"
  alias lla "ll -a"
end

alias vi "nvim"
alias g "git"

set -gx FZF_CTRL_T_OPTS "--height 60% \
--border sharp \
--layout reverse \
--prompt '∷ ' \
--pointer ▶ \
--marker ⇒"

set -gx FZF_TMUX 1
set -gx FZF_TMUX_OPTS "-p"

if [ -z "$TMUX" ]
	tmux attach -t default || tmux new -s default
end
