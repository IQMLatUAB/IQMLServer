function ip = tcp_ip
%TCP_IP Return the TCP IP number used by the job server.
[~, ipaddress] = system('hostname -I');
ip_prime = strsplit(ipaddress,' ');
ip = ip_prime{1,1};
end
