#Variables
sin=sshin
sout=sshout
win=wwwin
wout=wwwout
dport=53
dportrange=1024:65535
dchprange=67:68

#switches
udp="-p udp"
tcp="-p tcp"
d="--dport"
s="--sport"

#Setting Default Policies to DROP
iptables -F INPUT
iptables -P INPUT DROP
iptables -F FORWARD
iptables -P FORWARD DROP
iptables -F OUTPUT
iptables -P OUTPUT DROP

#Allow DNS and DCHP
iptables -A INPUT $udp $s $dport $d $dportrange -j ACCEPT
iptables -A OUTPUT $udp $d $dport $s $dportrange -j ACCEPT
iptables -A INPUT $udp $d $dchprange $s $dchprange -j ACCEPT
iptables -A OUTPUT $udp $s $dchprange $d $dchprange -j ACCEPT

#Create user-defined chains for accounting rules
iptables -N $sin
iptables -N $sout
iptables -N $win
iptables -N $wout

#Redirect to user-defined chains
iptables -A INPUT $tcp $d ssh -j $sin
iptables -A OUTPUT $tcp $s ssh -j $sout
iptables -A INPUT $tcp $d www -j $win
iptables -A OUTPUT $tcp $s www -j $wout

#Permit ssh inbound/outbound packet
iptables -A $sin $tcp $d ssh -j ACCEPT
iptables -A $sout $tcp $s ssh -j ACCEPT

#Permit www inbound/outbound packet
iptables -A $win $tcp $d www -j ACCEPT
iptables -A $wout $tcp $s www -j ACCEPT

#Deny from sport 0-1024 with dport 80
iptables -A $sin $tcp $d 80 $s 0:1024 -j DROP
iptables -A $win $tcp $d 80 $s 0:1024 -j DROP

#Deny from port 0
iptables -A $sin $tcp $d 0 -j DROP
iptables -A $win $tcp $d 0 -j DROP
