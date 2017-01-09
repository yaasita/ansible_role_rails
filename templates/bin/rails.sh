#!/bin/bash
#########################################
HOME=/home/{{ rails.user }}
CURRENT=/home/{{ rails.user }}/{{ rails.dir }}/current
#########################################

#rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

function start {
    cd $CURRENT
    if [ -e tmp/pids/unicorn.pid ];then
        pid=$(cat tmp/pids/unicorn.pid)
        if kill -0 $pid 2>/dev/null; then
            "unicorn was already running"
            return
        else
            rm tmp/pids/unicorn.pid
        fi
    fi
    echo "unicorn start"
    bundle exec unicorn_rails -E production -c config/unicorn.rb -D
}
function stop {
    cd $CURRENT
    if [ -e tmp/pids/unicorn.pid ];then
        pid=$(cat tmp/pids/unicorn.pid)
    else
        echo "unicorn was already stopping"
        return
    fi
    echo "unicorn stop"
    while kill -0 $pid 2>/dev/null; do
        echo "waiting for unicorn to die"
        kill $pid
        sleep 1
    done
    echo "unicorn stoped"
}

case "$1" in
	bundle)
        if [ "$2" = "" ]; then
          cd $CURRENT
        else
          cd $2 || exit 1
        fi
		echo "bundle start"
		bundle install --without development test || exit 1
		echo "db:migrate start"
		bundle exec rake db:migrate RAILS_ENV=production || exit 1
		echo "assets precompile start"
		bundle exec rake assets:precompile RAILS_ENV=production || exit 1
	;;
	start)
        start
	;;
	stop)
        stop
	;;
	restart)
        stop
        start
	;;
	*)
		echo "Error Argument"
		exit 1
	;;
esac
