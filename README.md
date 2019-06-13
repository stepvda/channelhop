# channelhop
Wifi channel hopping script for use with wireshark and other net pcap capture utlities. Designed for macos and apple airport network cards.

-initial version still bare bone. defenetely no bells and wistles-

What is it: sript that will automatically change wifi channel while capturing datat with a tool like Wireshark. This is quiet handy during initial discovery when you need to assess all the networks that are available.


## functionality:
 * Uses the apple `airport` tool that comes standard with macos. This means that this tool is only useful for apple's wifi adaptors.
 * Will test for the wifi card's capabilities by trying out each wifi channel to see which ones it can use.
 * Test result provides a list of wifi channels that is then used for wifi hopping 
 * For now hopping is pre-configured to occur every 0.5 second and this 5000 times. (press CTRL-C to exit)


Feel free to fork and edit. I'll add functionality as I use it more

## remarks:
 * script assumes network card is already in __monitor__ mode!!!
 * assumes only 1 wifi adaptor is present
 * Interval should not be higher then 1 second. Wireshark will appear as if it's not switching channels because it does not have enough data to send typically in a longer interval
 * Same topic, it helps to increase wireshark data buffer and capture size

## How to use with Wireshark