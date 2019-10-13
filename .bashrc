# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

# added by travis gem
[ -f /home/somdoron/.travis/travis.sh ] && source /home/somdoron/.travis/travis.sh
