# Set these options in your config.fish (if you want to :])
#
#     set -g theme_display_user yes
#     set -g theme_hostname never
#     set -g theme_hostname always
#     set -g default_user your_normal_user



# Backward compatibility
#
# Note: Do not depend on these behavior. These can be removed in anytime by the
# author in the name of code readability.
if set -q theme_hide_hostname
  # Existing $theme_hostname will always override $theme_hide_hostname
  if not set -q theme_hostname
    if [ "theme_hide_hostname" = "yes" ]
      set -g theme_hostname never
    end
    if [ "theme_hide_hostname" = "no" ]
      set -g theme_hostname always
    end
  end
end


#
# Segments functions
#
set -g current_bg NONE
set -g segment_separator \uE0B0

function prompt_segment -d "Function to draw a segment"
  set -l bg
  set -l fg
  if [ -n "$argv[1]" ]
    set bg $argv[1]
  else
    set bg normal
  end
  if [ -n "$argv[2]" ]
    set fg $argv[2]
  else
    set fg normal
  end
  if [ "$current_bg" != 'NONE' -a "$argv[1]" != "$current_bg" ]
    set_color -b $bg
    set_color $current_bg
    echo -n "$segment_separator"
    set_color -b $bg
    set_color $fg
  else
    set_color -b $bg
    set_color $fg
    if [ "$leading_separator_printed" = "no" ]
      echo -n "$segment_separator"
      set -g leading_separator_printed "yes"
    else
      echo -n ""
    end
  end
  set current_bg $argv[1]
  if [ -n "$argv[3]" ]
    echo -n -s $argv[3] ""
  end
end

function prompt_finish -d "Close open segments"
  if [ -n $current_bg ]
    set_color -b normal
    set_color $current_bg
    echo -n "$segment_separator "
  end
  set_color normal
  set -g current_bg NONE
end


function prompt_user -d "Display current user if different from $default_user"
  set -l BG 444444
  set -l FG BCBCBC

  if [ "$theme_display_user" = "yes" ]
    if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
      set USER (whoami)
      get_hostname
      if [ $HOSTNAME_PROMPT ]
        set USER_PROMPT $USER@$HOSTNAME_PROMPT
      else
        set USER_PROMPT $USER
      end
      prompt_segment $BG $FG $USER_PROMPT
    end
  else
    get_hostname
    if [ $HOSTNAME_PROMPT ]
      prompt_segment $BG $FG $HOSTNAME_PROMPT
    end
  end
end

function get_hostname -d "Set current hostname to prompt variable $HOSTNAME_PROMPT if connected via SSH"
  set -g HOSTNAME_PROMPT ""
  if [ "$theme_hostname" = "always" -o \( "$theme_hostname" != "never" -a -n "$SSH_CLIENT" \) ]
    set -g HOSTNAME_PROMPT (hostname | sed -e 's/\..*//')
  end
end


function prompt_dir -d "Display the current directory"
  prompt_segment $fish_color_autosuggestion white (prompt_pwd)
end

function prompt_git -d "Display the current git state"
  set -l ref
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set ref (command git symbolic-ref HEAD 2> /dev/null)
    if [ $status -gt 0 ]
      set -l branch (command git show-ref --head -s --abbrev |head -n1 2> /dev/null)
      set ref "➦ $branch "
    end
    set branch_symbol \uE0A0
    set -l branch (echo $ref | sed  "s-refs/heads/-$branch_symbol-")

    set -l BG PROMPT
    set BG green
    set PROMPT "$branch"

    prompt_segment $BG black $PROMPT
  end
end

function prompt_status -d "the symbols for a non zero exit status, root and background jobs"
    if [ $RETVAL -ne 0 ]
      prompt_segment black red "✘"
    end

    # if superuser (uid == 0)
    set -l uid (id -u $USER)
    if [ $uid -eq 0 ]
      prompt_segment black yellow "⚡"
    end

    # Jobs display
    if [ (jobs -l | wc -l) -gt 0 ]
      prompt_segment black cyan "⚙"
    end
end

#
# Prompt
#
function fish_prompt
  set -g leading_separator_printed no
  set -g RETVAL $status
  prompt_status
  prompt_user
  prompt_dir
  prompt_git
  prompt_finish
end
