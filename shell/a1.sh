#Variables
sin=sshin
sout=sshout
win=wwwin
wout=wwwout
dport=53
dportrange=1024:65535
dchprange=67:68
https=443

#switches
udp="-p udp"
tcp="-p tcp"
d="--dport"
s="--sport"

#Setting Default Policies to DROP
iptables -F
iptables -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

#Create user-defined chains for accounting rules
iptables -N $sin
iptables -N $sout
iptables -N $win
iptables -N $wout

#Redirect to user-defined chains
iptables -A INPUT $tcp $d ssh -j $sin
iptables -A OUTPUT $tcp $s ssh -j $sout
iptables -A INPUT $tcp $s www -j $win
iptables -A OUTPUT $tcp $d www -j $wout
iptables -A INPUT $tcp $s $https -j $win
iptables -A OUTPUT $tcp $d $https -j $wout

#Permit ssh inbound/outbound packet
iptables -A $sin $tcp $d ssh -j ACCEPT
iptables -A $sout $tcp $s ssh -j ACCEPT

#Permit www inbound/outbound packet
iptables -A $win $tcp $s www $d $dportrange -j ACCEPT
iptables -A $wout $tcp $s $dportrange $d www -j ACCEPT
iptables -A $win $tcp $s $https $d $dportrange -j ACCEPT
iptables -A $wout $tcp $s $dportrange $d $https -j ACCEPT

#Allow DNS and DCHP

#DNS
iptables -A OUTPUT $udp $s $dportrange $d $dport -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT $udp $s $dport $d $dportrange -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT $tcp $s $dportrange $d $dport -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT $tcp $s $dport $d $dportrange -m state --state ESTABLISHED -j ACCEPT

#DCHP
iptables -A INPUT $udp $d $dchprange $s $dchprange -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT $udp $s $dchprange $d $dchprange -m state --state NEW,ESTABLISHED -j ACCEPT

#Deny from sport 0-1024 with dport 80
iptables -A INPUT $d 80 $s 0:1024 -j DROP

#Deny from port 0
iptables -A INPUT $d 0 -j DROP
iptables -A INPUT $s 0 -j DROP