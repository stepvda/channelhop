#!/bin/bash

# Wifi channel hopper for wireshark and so on. developped for MacOS and airport network adaptors

#REQUIREMENTS: zsh (get it on homebrew), airport utility (part of macos) 

#check if running as sudo
if [ ! -z "$SUDO_USER" -a "$SUDO_USER" != " " ]; then
    echo "check: running as sudo. ok."
else
    echo "error: must run as sudo, existing...."
    exit
fi


#create shortcut to airport util if not existing yet
airplnk="/usr/local/bin/airport"
check_AirTool() {
    if [ ! -f $airplnk ]; then
        echo "fixing: need to create airport util shortcut"
        ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport airport
        mv airport /usr/local/bin
        if [ ! -f $airplnk ]; then
            echo "error: failed to create shortcut to airport tool, exiting..."
        else
            echo "success: shortcut creation confirmed"
        fi
    else
        echo "check: airport util shortcut exists. ok."
    fi
}
check_AirTool


channels25=(1 2 3 4 5 6 7 8 9 10 11 12 13 14)
channels5A=(36 40 44 48)
#channels5B=(100 104 108 112 116 120 124 128 132 136 140)
#channels5C=(149 153 157 161 165)
channels5B=(100 104)
channels5C=()
#Note: channels arrays that are commented are supported by the airport wifi adaptor on imac but apparently not by the os or wireshark. For this reason I disabled them. Would be interesting to see how this behaves with other versions of macos and perhaps more recent wifi cards. 
  
list_channels () {
    echo "2.5GHz:"
    for elem in ${channels25[@]}; do
        echo $elem
    done
    echo "5GHz - list A"
    for elem in ${channels5A[@]}; do
        echo " $elem"
    done
    echo "5GHz - list B"
    for elem in ${channels5B[@]}; do
        echo " $elem"
    done
    echo "5GHz - list C"
    for elem in ${channels5C[@]}; do
        echo " $elem"
    done
}
#list_channels

#check if airport is on
check_on () {
  zsh -c "echo -en 'check: if airport radio is turned on...    \c'"
  sleep 0.5
  if [ `sudo airport -I | grep "AirPort: Off" | wc -l;` -eq 1 ] ; then 
     zsh -c "echo -en '\rcheck: if airport radio is turned on. error: radio off. turn on radio and try again. exiting...     \c'"
     exit
     exit
  else
     zsh -c "echo -en '\rcheck: if airport radio is turned on. ok.     \c'"
  fi
  echo
 
}
check_on

#desociate from any wifi network
desos () {
    zsh -c "echo -en '\rcheck: desociating from any wifi network....\c'"

    if sudo airport -z; then
        zsh -c "echo -en '\rcheck: desociating from any wifi network. ok.     \c'"
    else 
        zsh -c "echo -en '\rcheck: desociating from any wifi network. error ${res}. exiting...    \c'"
        exit
        exit
    fi
    #airpoecho
    echo
}
desos

declare -a testedChannels
testedChannels=()
curChan=0
test_channels () {
    zsh -c "echo -en '\rTesting 2.5GHz - list\c'"
    for elem in ${channels25[@]}; do
        curChan=$elem
        test_channel
    done
    zsh -c "echo -en '\rTesting 5GHz - list A\c'"
    for elem in ${channels5A[@]}; do
        curChan=$elem
        test_channel
    done
    zsh -c "echo -en '\rTesting 5GHz - list B\c'"
    for elem in ${channels5B[@]}; do
        curChan=$elem
        test_channel
    done
    zsh -c "echo -en '\rTesting 5GHz - list C\c'"
    for elem in ${channels5C[@]}; do
        curChan=$elem
        test_channel
    done

    zsh -c "echo -en '\rtesting done. available channels: ${#testedChannels[@]}\c'"
  #  echo "Available channels: ${#testedChannels[@]}"
    for elem in ${testedChannels[@]}; do
       zsh -c "echo -en '$elem \c'"
    done
}

test_channel () {
    sudo airport -c${curChan}
    res=`sudo airport -I | grep "channel:" | awk '{print($2)}'`
    #echo "ch: ${curChan} - res: ${res}"
    if [ $curChan -eq $res ] ; then 
        testedChannels+=( "${curChan}" )
    fi
}
test_channels


hopInterval=0.5
hops=5000
curChan=0
hop () {
    echo
    cnt=${#testedChannels[@]}
    chanCnt=${#testedChannels[@]}
    chanIdx=0
    while (( $hops > 0 )) ; do
        
        (( cnt+=1 ))
        (( hops-=1 ))
        chanIdx=$(( ${cnt} % ${chanCnt} ))
        curChan=${testedChannels[$chanIdx]}
        zsh -c "echo -en '\rhopping every ${hopInterval} seconds, ${hops} times left, current channel: ${curChan}     \c'"
        sudo airport -c${curChan}
        sleep ${hopInterval}

    done
}
hop

##WIFI Channels reference guide
# 	2.4 GHz ISM : 2400 - 2500 MHz
# 	ch	freq		regs
# 	2	2417 	    -
# 	1	2412		-
# 	3	2422		-
# 	4	2427		-
# 	5	2432		-
# 	6	2437		-
# 	7	2442		-
# 	8	2447		-
# 	9	2452		-
# 	10	2457		-
# 	11	2462		-
# 	12	2467		NA in US
# 	13	2472		NA in US
# 	14	2484		NA in US
#
# 	5 GHz Low :  5250 MHz
￼#   ch	 freq	    regs
# 	36	5180		-
# 	40	5200		-
# 	44	5220		-
# 	48	5240		-
#
# 	5 GHz Mid :  5330 MHz
#	ch	freq		regs
# 	52	5260		DFS
# 	56	5280		DFS
# 	60	5300		DFS
# 	64	5320		DFS
#
# 	5 GHz World  - 5650 MHz
# 	ch	freq		regs
# 	100	5500		DFS
# 	104	5520		DFS
# 	108	5540		DFS
# 	112	5560		DFS
# 	116	5580		DFS
# 	120	5600		NA in US
# 	124	5620		NA in US
# 	128	5640		NA in US
# 	132	5660		DFS
# 	136	5680		DFS
# 	140	5700		DFS
#
# 	5 GHz Upper  - 5835 MHz
# ￼	 ch	 freq		regs
# 	149	5745		-
# 	153	5765		-
# 	157	5785		-
# 	161	5805		-
# 	165	5825		-
