#Variables
sin="sshin"
sout="sshout"
win="wwwin"
wout="wwwout"

#Ports
dnsRange="1024:65535"
dchpRange="67:68"
dnsPort="53"

#Setting Default Policies to DROP
iptables -F INPUT
iptables -P INPUT DROP
iptables -F FORWARD
iptables -P FORWARD DROP
iptables -F OUTPUT
iptables -P OUTPUT DROP

#Allow DNS and DCHP
iptables -A INPUT -p udp --sport $dnsPort --dport $dnsRange -j ACCEPT
iptables -A OUTPUT -p udp --dport $dnsPort --sport $dnsRange -j ACCEPT
iptables -A INPUT -p tcp --sport $dnsPort --dport $dnsRange -j ACCEPT
iptables -A OUTPUT -p tcp --dport $dnsPort --sport $dnsRange -j ACCEPT
iptables -A INPUT -p udp --dport $dchpRange --sport $dchpRange -j ACCEPT
iptables -A OUTPUT -p udp --sport $dchpRange --dport $dchpRange -j ACCEPT

#Create user-defined chains for accounting rules
iptables -N $sin
iptables -N $sout
iptables -N $win
iptables -N $wout

#Redirect to user-defined chains
iptables -A INPUT -p tcp --dport ssh -j $sin
iptables -A OUTPUT -p tcp --sport ssh -j $sout
iptables -A INPUT -p tcp --dport www -j $win
iptables -A OUTPUT -p tcp --sport www -j $wout

#Permit ssh inbound/outbound packet
iptables -A $sin -p tcp --dport ssh -j ACCEPT
iptables -A $sout -p tcp --sport ssh -j ACCEPT

#Permit www inbound/outbound packet
iptables -A $win -p tcp --dport www -j ACCEPT
iptables -A $wout -p tcp --sport www -j ACCEPT

#Deny from sport 0-1024 with dport 80
iptables -A $sin -p http --dport 80 --sport 0:1024 -j DROP
iptables -A $win -p http --dport 80 --sport 0:1024 -jDROP

#Deny from port 0
iptables -A $sin --dport 0 -j DROP
iptables -A $win --dport 0 -j DROP
