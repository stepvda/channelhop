# channelhop
Wifi channel hopping script for use with wireshark and other net pcap capture utilities. Designed for macos and apple airport network cards.

-initial version still bare bone. definitely no bells and wistles-

What is it: script that will automatically change wifi channel while capturing data with a tool like Wireshark. This is quiet handy during initial discovery when you need to assess all the networks that are available.

With this tool you can scan all networks in the area and not just those one one channel. 

❗Note that hopping channels inherently means you will loose data from any network conversation. This is therefore only useful when you're interested in who's out there NOT for when you want to know what is being exchanged. 


## functionality:
 * Uses the apple `airport` tool that comes standard with macos. This means that this tool is only useful for apple's wifi adapters.
 * Will test for the wifi card's capabilities by trying out each wifi channel to see which ones it can use.
 * Test result provides a list of wifi channels that is then used for wifi hopping 
 * For now hopping is pre-configured to occur every 0.5 second and this 5000 times. (press CTRL-C to exit)
 * Will check for the airport tool and create a symlink to it under `/usr/local/bin` which is typically included in your env $PATH so that you can launch it from anywhere.
 * Checks if script is being launched as __sudo__ which is required for the airport tool.


Feel free to fork and edit. I'll add functionality as I use it more

## remarks:
 * script assumes network card is already in __monitor__ mode!!!
 * assumes only 1 wifi adapter is present
 * Interval should not be higher then 1 second. Wireshark will appear as if it's not switching channels because it does not have enough data to send typically in a longer interval
 * Same topic, it helps to increase wireshark data buffer and capture size
 * Commented out channels above 104. Even though my airport card supports some of them either the os or wireshark doesn't.  
 
>❔Does anyone know where this limitation sits? Just uncomment is you want ot try all channels.


## How to use with Wireshark

 1. start wireshark (sudo is not needed)
 2. if you previously launched the script or did anything else with your airport card turn it off and on again from the menu bar for instance. Sometimes wireshark will otherwise not receive any data.
 3. start capturing data, default settings are fine normally with high enough buffer and capture size.
 ![](lib/wireshark_intf_config.png)  
 4. launch the script from a terminal as __sudo__ by typing:  
 ````bash
 sudo ./channelhop.sh
 ````
 this should output something like this:
 ````
 $ /Volumes/nstephane/Dev/Command_line/channelhop.sh
check: running as sudo. ok.
check: airport util shortcut exists. ok.
Testing 5GHz - list C
Available channels: 19
1 2 3 4 5 6 7 8 9 10 11 12 13 36 40 44 48 100 104
hopping every 0.5 seconds, 4974 times left, current channel: 8
````
 5. In wireshark you should start to see the channel hopping like in this screenshot:  
 ![](lib/wireshark_hopping.png)

 In case you have't done so already you might want to add a column in wireshark to display the channel. The field for this is `wlan_radio.channel` 

 ## Wireshark command line example to capture all devices in range

 ````bash
 tshark -i en1 -T fields -e wlan.ta -e wlan.ra -e wlan_radio.channel -e wlan.ssid -l -I
 `````

This example launch wireshark from the command line and tell it just to output the mac addresses of senders and receivers, channel and possible ssid. All this in monitoring mode without connecting to any network and thanks to __channelhop__ search every channel.

This will output something like this to the terminal screen (not to a pcap file in this example):
```
Capturing on 'Wi-Fi: en1'
5c:96:9d:69:0f:ba	ff:ff:ff:ff:ff:ff	104	homer
5c:96:9d:69:0f:ba	33:33:ff:64:e3:38	104
5c:96:9d:69:0f:ba	ff:ff:ff:ff:ff:ff	104	homer
5c:96:9d:69:0f:ba	ff:ff:ff:ff:ff:ff	104	homer
5c:96:9d:69:0f:ba	ff:ff:ff:ff:ff:ff	104	homer
5c:96:9d:69:0f:ba	ff:ff:ff:ff:ff:ff	104
5c:96:9d:69:0f:ba	ff:ff:ff:ff:ff:ff	104
	f4:bf:80:db:b8:3e	1
10:13:31:74:ba:1b	ff:ff:ff:ff:ff:ff	1	vanvlxemDubois1
	f4:bf:80:db:b8:3e	1
dc:53:7c:bf:db:8b	ff:ff:ff:ff:ff:ff	1	Mobstar-FDB82
da:fb:5e:9e:bb:cb	ff:ff:ff:ff:ff:ff	1	Guest-range-cb
```
🌠 Notice how many broadcast messages are sent over wifi with the hi-address. Also not all messages wireshark is picking up will have a sender and a receiver. SSID will also not always be part of the packet.

👉 From this example you can extend this command with basic filtering such as with `grep` to search for specific fields. For example if you're looking for a specific mac-address that contains _ab:cd_ you could use something like this:
````bash
 tshark -i en1 -T fields -e wlan.ta -e wlan.ra -e wlan_radio.channel -e wlan.ssid -l -I | grep "ab:cd"
````
 
