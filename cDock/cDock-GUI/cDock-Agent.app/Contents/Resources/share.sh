#! /bin/bash

dir_check() {
	if [[ ! -e "$1" ]]; then mkdir -pv "$1"; fi
}

update_check() {
	cur_date=$(date "+%y%m%d")
  	lastupdateCheck=$($PlistBuddy "Print lastupdateCheck:" "$cdock_pl" 2>/dev/null || defaults write org.w0lf.cDock "lastupdateCheck" 0 2>/dev/null)
	if [[ "$5" = "w" ]]; then
  		weekly=$((lastupdateCheck + 7))
    	if [[ "$weekly" = "$cur_date" ]]; then
    		update_check_step2 "$1" "$2" "$3" "$4"
    	fi
  	elif [[ "$5" = "n" ]]; then
  		update_check_step2 "$1" "$2" "$3" "$4"
	else
		if [[ "$lastupdateCheck" != "$cur_date" ]]; then
  			update_check_step2 "$1" "$2" "$3" "$4"
  		fi
  	fi
}

update_check_step2() {
	results=$(ping -c 1 -t 5 "https://www.github.com" 2>/dev/null || echo "Unable to connect to internet")
	if [[ $results = *"Unable to"* ]]; then
		echo "ping failed : $results"
	else
		echo "ping success"
		beta_updates=$($PlistBuddy "Print betaUpdates:" "$cdock_pl" 2>/dev/null || echo -n 0)
	    update_auto_install=$($PlistBuddy "Print autoInstall:" "$cdock_pl" 2>/dev/null || { defaults write org.w0lf.cDock "autoInstall" 0; echo -n 0; } )

	    # Stable urls
	    dlurl=$(curl -s https://api.github.com/repos/w0lfschild/cDock/releases/latest | grep 'browser_' | cut -d\" -f4)
	    verurl="https://raw.githubusercontent.com/w0lfschild/cDock/master/_resource/version.txt"
	    logurl="https://raw.githubusercontent.com/w0lfschild/cDock/master/_resource/versionInfo.txt"

	    defaults write org.w0lf.cDock "lastupdateCheck" "${cur_date}"
	    "$1" c "$2" org.w0lf.cDock "$3" "$verurl" "$logurl" "$dlurl" "$4" &
  	fi
}

vercomp() {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

verres() {
	vercomp "$1" "$2"
	case $? in
		0) output='=';;
        1) output='>';;
        2) output='<';;
	esac
	echo $output
}
