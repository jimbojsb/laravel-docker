WHERE=${APP_ENV^^}

if [ $APP_ENV == "production" ]
then
  COLOR="\e[31m"
else
  COLOR="\e[32m"
fi

export PS1="[\[$COLOR\]\$WHERE\[\e[m\]\[\e[33m\]@\[\e[m\]\[\e[36m\]\$APP_NAME\[\e[m\] \[\e[35m\]\w\[\e[m\]\[\e[37m\]]\[\e[m\]\[\e[37m\]\\$\[\e[m\] "