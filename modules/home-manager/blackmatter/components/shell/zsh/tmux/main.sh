[ -z $TMUX_RPOJECT ] && TMUX_PROJECT=default
[ -z $TMUX_PLUGINS ] && TMUX_PLUGINS=$TMUX_HOME/plugins
! [ -d $TMUX_HOME ] && mkdir -p $TMUX_HOME
! [ -z "$TMUX_AUTO_ON" ] && if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
	tmux attach -t $TMUX_PROJECT || tmux new -s $TMUX_PROJECT
fi
