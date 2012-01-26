#Variables
sin=sshin
sout=sshout
win=wwwin
wout=wwwout

#Setting Default Policies to DROP
iptables -F INPUT
iptables -P INPUT DROP
iptables -F FORWARD
iptables -P FORWARD DROP
iptables -F OUTPUT
iptables -P OUTPUT DROP

#Allow DNS and DCHP
iptables -A INPUT -p udp --sport 53 --dport 1024:65535 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 --sport 1024:65535 -j ACCEPT
iptables -A INPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT
iptables -A OUTPUT -p udp --sport 67:68 --dport 67:68 -j ACCEPT

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
iptables -A $sout -p tcp --dport ssh -j ACCEPT

#Permit www inbound/outbound packet
iptables -A $win -p tcp --dport www -j ACCEPT
iptables -A $wout -p tcp --dport www -j ACCEPT

#Deny from sport 0-1024 with dport 80
iptables -A $sin -p tcp --dport 80 --sport 0:1024 -j DROP
iptables -A $win -p tcp --dport 80 --sport 0:1024 -j DROP

#Deny from port 0
iptables -A $sin -p tcp --dport 0 -j DROP
iptables -A $win -p tcp --dport 0 -j DROP
