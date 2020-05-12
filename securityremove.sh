#!/bin/bash
#########################################################################
# File Name: securityremove.sh
# Author: Gavin
#
# Version:
# Created Time: 2019年02月28日 星期日 17时47分37秒
#########################################################################
 
RMARGS="${@}"
RMPATH="/bin/rm"
sys1dir=$(ls / | sed 's/^/\//' | tr "\n" " " | sed 's/.$//')
[ "${RMARGS}" == "" ] && ${RMPATH} && exit
 
SBRUN() {
        echo -ne "\033[41;37mWhy run this command\033[0m\n"
        exit 255
}
 
if grep "$sys1dir" <<< $RMARGS >/dev/null 2>&1; then SBRUN;fi
for i in ${@};do [ "$i" = "/" ] && SBRUN ;done
 
if [ "${RMARGS}" == '-h' ] || [ "${RMARGS}" == '--help' ];then
        ${RMPATH} ${RMARGS}
else
        while [ "${confirm}" != "yes" ] && [ "${confirm}" != "no" ]; do
                echo -ne "You are going to execute \"${RMPATH} \033[41;37m${RMARGS}\033[0m\",please confirm (yes or no):"
                read confirm
        done
        [ "${confirm}" == "yes" ] && ${RMPATH} ${RMARGS} || exit
fi