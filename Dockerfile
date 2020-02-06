FROM alpine:edge

MAINTAINER Jaka Hudoklin <offlinehacker@users.noreply.github.com>

RUN apk add --no-cache bash iptables dhcp docker iproute2 iw
RUN apk add --no-cache --virtual .build-deps make gcc openssl-dev libnl3-dev linux-headers libc-dev
COPY CVE-2019-16275.patch /CVE-2019-16275.patch
RUN wget -O /hostapd.tgz http://w1.fi/releases/hostapd-2.9.tar.gz && tar xf /hostapd.tgz && cd /hostapd-2.9/ && patch -p1 -i /CVE-2019-16275.patch && cd hostapd && sed \
		-e '/^#CONFIG_DRIVER_NL80211=y/s/^#//' \
		-e '/^#CONFIG_RADIUS_SERVER=y/s/^#//' \
		-e '/^#CONFIG_DRIVER_WIRED=y/s/^#//' \
		-e '/^#CONFIG_DRIVER_NONE=y/s/^#//' \
		-e '/^#CONFIG_IEEE80211N=y/s/^#//' \
		-e '/^#CONFIG_IEEE80211R=y/s/^#//' \
		-e '/^#CONFIG_IEEE80211AC=y/s/^#//' \
		-e '/^#CONFIG_FULL_DYNAMIC_VLAN=y/s/^#//' \
		-e '/^#CONFIG_LIBNL32=y/s/^#//' \
		-e '/^#CONFIG_ACS=y/s/^#//' \
		defconfig >> .config && echo "CONFIG_SAE=y" >> .config && make && \
     cp /hostapd-2.9/hostapd/hostapd /usr/sbin/ && \
     apk del .build-deps && rm -rf /hostapd* /CVE-2019-16275.patch

RUN echo "" > /var/lib/dhcp/dhcpd.leases
ADD wlanstart.sh /bin/wlanstart.sh

ENTRYPOINT [ "/bin/wlanstart.sh" ]
