#!/bin/bash

usage () {
	echo "Usage :"
	echo "  -m | --mac  [xx:xx:xx:xx:xx]   Allows you to recover vendor name from mac address"
	echo "  -v | --vendor  [vendor name]   Allows you to recover mac address list from vendor name"
	echo "  -h | --help                    Prints this page"
}

update () {
	echo "Updating oui.txt ..."
	wget -q -O - http://standards-oui.ieee.org/oui/oui.txt | grep '(base 16)' | tr -s '\t' ' ' | sed 's/ (base 16)//g' | sort > oui.txt
	echo "Done !"
}

get_vendor () {
	mac=$(echo $1 | tr '[:lower:]' '[:upper:]' | sed 's/[^[:xdigit:]]//g' | tr -d '\n' | cut -c-6 -)
	vendor=$(grep $mac oui.txt | cut -c8- -)
	if [ "$vendor" != "" ]; then
		echo $1 $vendor
	else
		echo "No vendor found for "$1
	fi
	exit
}

get_mac () {
	vendor=$(grep -i $1 oui.txt | cut -c-6 - | sed 's/.\{2\}/&:/g')
	let count=0
	for l in $vendor; do
		echo $l"xx:xx"
		let count=count+1
	done
	echo "FOUND $count MAC ADDRESSES"
}

if [ ! -f "oui.txt" ]; then
	echo "File oui.txt not found !"
	echo "Downloading ..."
	wget -q -O - http://standards-oui.ieee.org/oui/oui.txt | grep '(base 16)' | tr -s '\t' ' ' | sed 's/ (base 16)//g' | sort > oui.txt
	echo "Done !"
fi


if [ "$1" = "" ]; then
	usage	
fi
while [ "$1" != "" ]; do
	case $1 in
		-m | --mac )
			shift
			if [ "$1" != "" ]; then
				get_vendor $1
			else
				usage	
			fi
			;;
		-v | --vendor )
			shift
			if [ "$1" != "" ]; then
				get_mac $1
			else
				usage	
			fi
			;;
		-u | --update )
			update
			exit
			;;
		* )
			usage
			exit
			;;
	esac
	shift
done
