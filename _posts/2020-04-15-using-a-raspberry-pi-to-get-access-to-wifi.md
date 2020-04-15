---
layout: post
title: Using a Raspberry Pi to get access to Wifi
---

I have a Wifi stick to connect to a wireless network, but unfortunately the
vendor did not care to supply a reliable Linux driver, and the connection every
so often gets lost. Since I also have a Raspberry Pi, I wanted to try and use
that for internet access via ethernet cable. Having used the setup for almost a
week now, I can say that it is better than the previous one although the Wifi
router does not seem to be the best either, because the connection quality
significantly decreases when there is lots of traffic.

Anyway, I configured my Raspberry using [these][rpi-forum-howto]
[howtos][willhaley-howto] and [docs][rpi-doc-wifi]. The following instructions
are a blend of what I found in there. They assume you have already connected
your machine (most likely a desktop computer) to the interface named `eth0`
using an ethernet cable. In this guide, `eth0` is given the address
`192.168.2.1`.

First, install [dnsmasq][wikipedia-dnsmasq] which is used as a DHCP server to
provide your machine with an IP address.

```
sudo apt install dnsmasq
```

Edit `/etc/dnsmasq.conf` and add the following values:

```
interface=eth0
listen-address=192.168.2.1
bind-interfaces
domain-needed
bogus-priv
dhcp-range=192.168.2.50,192.168.2.150,12h
```

This will configure `dnsmasq` to use addresses starting from `192.168.2.50`.

Edit `/etc/dhcpcd.conf` and add the following at the end to configure `eth0`
with a static address:

```
interface eth0
    static ip_address=192.168.2.1/24
```

Now restart `dhcpcd` to make the new settings go into effect:

```
sudo service dhcpcd restart
```

Configure port forwarding as described [in the docs][rpi-doc-wifi]:

> Edit `/etc/sysctl.conf` and uncomment this line:
>
> ```
> net.ipv4.ip_forward=1
> ```
>
> Add a masquerade for outbound traffic on `eth0`:
>
> ```
> sudo iptables -t nat -A  POSTROUTING -o wlan0 -j MASQUERADE
> ```
>
> Save the iptables rule.
>
> ```
> sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
> ```
>
> Edit `/etc/rc.local` and add this just above "exit 0" to install these rules
> on boot.
>
> ```
> iptables-restore < /etc/iptables.ipv4.nat
> ```
>
> Reboot and ensure it still functions.

Now, your machine will automatically get an IP address when it is connected to
the Rapsberry, and it will, assuming the Pi is itself connected, use that
connection to access the internet.

[rpi-forum-howto]: https://www.raspberrypi.org/forums/viewtopic.php?t=132674
[rpi-doc-wifi]: https://www.raspberrypi.org/documentation/configuration/wireless/access-point.md
[wikipedia-dnsmasq]: https://en.wikipedia.org/wiki/Dnsmasq
[willhaley-howto]: https://willhaley.com/blog/raspberry-pi-wifi-ethernet-bridge/
