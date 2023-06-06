# Raspberry PI CM4 Router

![Picture of Raspberry PI CM4 Router and case](https://cdn.thingiverse.com/assets/b8/af/7f/db/4e/ca2ceb83-f754-49b0-9868-e4a4f9d41c15.jpg).

Case for a [Raspberry PI CM4](https://www.raspberrypi.com/products/compute-module-4/?variant=raspberry-pi-cm4001000) and the [Raspberry Pi Compute Module 4 IoT Router Carrier Board Mini](https://www.dfrobot.com/product-2242.html).

Dual Gigabit ethernet using the built-in interface `eth0` and the PCI Express interface `eth1`.

* [dfr0767-v1.0.scad](dfr0767-v1.0.scad) .
* STL files and additional images are on the [related Thingiverse page](https://www.thingiverse.com/thing:6064249).

## Hardware

The [Raspberry PI CM4104000 I bought came with a fan](https://www.amazon.com/dp/B0BXCXDHC5) and some basic hardware. It was WAY overpriced due to the current Raspberry supply shortage.

### Mounting Hardware

The bolts that came with it are perfect for mounting the heatsink to the CM4, but that's it. The nuts are even too thick to plug the CM4 into the carrier board. I replaced the bolts with M2.5x20mm bolts and used nylon washers between the CM4 and the carrier board. This leaves a good ~10mm of thread below the carrier board, helping to align and secure the board in the case. The bolts slide into case a provide shear strength but only minimal friction vertically.

![Empty case showing four holes for M2.5 bolts to slide into](https://cdn.thingiverse.com/assets/37/33/74/08/2c/featured_preview_3509a7cc-4fee-46be-89d3-2338e3974b19.jpg)

Here's how the hardware stacks up for each of the four bolts:

![Side view](https://cdn.thingiverse.com/assets/1e/8f/ca/f3/1a/e89d0ec9-f19c-49e2-9cfa-37d98f834e90.jpg)

1. Bolt (M2.5x20mm).
2. Metal flat washer (M2.5).
3. Heatsink.
4. Computer Module 4.
5. Nylon washer (M5 since thickness is the important part for this one).
6. Router carrier board.
7. Nylon washer (M3).
8. Metal flat washer (M2.5).
9. Metal nut (M2.5).

### Fan GPIO Pins

* `Red` +5V (pin 4).
* `Blue` GPIO 18 (pin 12).
* `Black` GND (pin 14).

## Software

This is a summary of what was done. There are much more detailed guides available elsewhere.

### Set up SDCard

1. Use Raspberry Pi imager
    1. Operating System: Raspberry PI OS Lite (64-bit)
    2. Storage (Likely /dev/sda if no SATA drives are present)
    3. Gear Icon
        1. Set hostname: _myhostname_
        2. Enable SSH
        3. Set username and password
    4. Write
2. _(optional)_ Mount and edit config.txt to enable the serial console :

        [all]
        enable_uart=1

### Configure OS

1. Boot up the new router using the SDCard. You'll want to watch your existing DHCP server to see what IP address it assigns to `eth1`. Then you _should_ be able to SSH into it.

2. Install latest OS updates

        apt update
        apt upgrade

3. _(optional)_ Create SSH authorized_keys. Paste your public key into ~/.ssh/authorized_keys then make sure that the permissions are correct.

        chmod -R go-rwX ~/.ssh

4. Configure static IP address for eth1 by editing `etc/dhcpcd.conf`. Set `routers` and `domain_name_servers` to your existing router and DNS servers.

        interface eth1
        static ip_address=192.168.0.2/24
        static routers=192.168.0.1 # Remove this after being placed in service as a router.
        static domain_name_servers=192.168.0.1

5. Enable fan control. _This may be optional since I have yet to see the temp go above 60. A passive heatsink may be sufficient._
    1. Install `rpi.gpio` if you want to manually test the fan using Python. _Hint use GPIO 18_.

        sudo apt-get install rpi.gpio
    2. Configure fan control.

        sudo raspi-config
    3. `4 Performance Options` -> `P4 Fan` -> `Pin 18` -> `Temp` `60`.

6. Set `eth1` MAC address on boot. _Otherwise it is random each time you boot up_.
    1. Create `/usr/local/bin/set_mac.sh` and change the mac address to whatever you like. I suggest using `eth0`'s address and incrementing by 1.

            #!/bin/sh

            ip link set eth1 address "e4:5f:01:aa:aa:aa"

    2. Set to run on startup.

            chmod a+x /usr/local/bin/set_mac.sh
            echo "sh /usr/local/bin/set_mac.sh" | sudo tee -a /etc/rc.local

## Configure Routing

* WAN: `eth0`
* LAN: `eth1`
* Home network: `192.168.0.0/24` _change as needed_.
* Existing home router: `192.168.0.1` _change as needed_.

1. Enable IP forwarding.

        echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/90-ip_forward.conf
        sudo sysctl net.ipv4.ip_forward=1

2. Install `iptables-persistent`. _Don't bother saving current rules when prompted._

        sudo apt install iptables-persistent

3. Create `/etc/iptables/rules.v6` .

        *filter
        :INPUT DROP [0:0]
        :FORWARD DROP [0:0]
        :OUTPUT DROP [0:0]
        COMMIT

4. Test `/etc/iptables/rules.v6` .

        sudo ip6tables-restore -t /etc/iptables/rules.v6

5. Create `/etc/iptables/rules.v4` . See [iptables.v4](iptables.v4) for an example. There's a lot here... you'll want to change this to suite your needs. This example:
    * Drops by default.
    * Allows SSHing into the router from the local network.
    * Port forwards `443` to the internal server `192.168.0.199` on port `443`.
    * Uses NAT loopback (a.k.a. hairpin) to allow internal clients to reach the internal server using the WAN IP. _LATER: This won't work when the WAN IP (ex. `1.2.3.4`) changes to something new._
6. Test `/etc/iptables/rules.v4` .

        sudo ip6tables-restore -t /etc/iptables/rules.v4

7. Apply IPv4 and IPv6 rules.

        sudo service netfilter-persistent reload

### Dynamic DNS

_Optional_. [Hurricane Electric offers free Dynamic DNS](https://dns.he.net/).

1. Set up a Dynamic DNS entry and configure a token for authentication.
2. Install `ddclient`.

        sudo apt install ddclient

3. Set options when prompted:
    * Provider: `Other`
    * Protocol: `dyndns2`
    * Server: `dyn.dns.he.net`
    * Username: `myhouse.dynamic.example.com`
    * Password: _This is where the token goes_
    * Discovery: `Interface`
    * Interface: `eth0` (Uses IP address dynamically assigned by your ISP).
    * Hosts to update: `myhouse.dynamic.example.com`

4. Verify options by looking at `/etc/ddclient.conf`.

        # Configuration file for ddclient generated by debconf
        #
        # /etc/ddclient.conf

        protocol=dyndns2 \
        use=if
        if=eth0
        server=dyn.dns.he.net \
        login=myhouse.dynamic.example.com \
        password='REDACTED' \
        myhouse.dynamic.example.com

### Send logs to your central syslog server

_Optional. But then again... doesn't everyone run a centralized syslog server at home?_

1. Create `/etc/rsyslog.d/remote.conf`

        *.* @192.168.0.5

## Related Links

* [Two Tiny Dual-Gigabit Raspberry Pi CM4 Routers | Jeff Geerling](https://www.jeffgeerling.com/blog/2021/two-tiny-dual-gigabit-raspberry-pi-cm4-routers)
* [Raspberry Pi Compute Module 4 datasheet](https://datasheets.raspberrypi.com/cm4/cm4-datasheet.pdf)
* [CM4 IoT Router Board Mini for Raspberry Pi Compute Module 4 Wiki - DFRobot](https://wiki.dfrobot.com/Compute_Module_4_IoT_Router_Board_Mini_SKU_DFR0767)
* [ZP-0112 - 52Pi Wiki (fan)](https://wiki.52pi.com/index.php?title=ZP-0112)
