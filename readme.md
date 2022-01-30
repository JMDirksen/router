# OS

Ubuntu Server 20.04


# Setup

    sudo -s
    cd
    git clone https://github.com/JeftaDirksen/router.git

    apt install isc-dhcp-server bind9


# Run at startup

    crontab -e
      SHELL=/bin/bash
      PATH=/usr/bin:/bin:/usr/sbin
      @reboot ./router/startup.sh >> crontab.log 2>&1
