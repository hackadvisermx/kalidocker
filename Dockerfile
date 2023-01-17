FROM kalilinux/kali-bleeding-edge as baseline

    RUN \
        apt update -y && \
        DEBIAN_FRONTEND="noninteractive" apt-get -y install  \
        apache2 \
        binwalk \
        chisel \
        curl \
        default-mysql-client \
        dnsenum \
        dnsrecon \
        dnsutils \
        foremost \
        fping \
        ffuf \
        host \
        iputils-ping \
        openvpn \
        nano \
        nbtscan \
        netcat-traditional \
        nmap \
        metasploit-framework \
        pip \
        python3 \
        radare2 \
        smbclient \
        socat \
        sqlite3 \
        squid \
        tcpdump \
        tmux \
        unzip \
        wget \
        vim \
        whois \
        zsh 

FROM baseline as builder 
    RUN \
        # Borra el mensaje por defecto de kali 
        touch /root/.hushlogin && \
         # Configuracion de Apache y Squid
	    sed -i 's/Si Funciona!/Funciona desde el contenedor!/g' /var/www/html/index.html && \
        echo "http_access allow all" >> /etc/squid/squid.conf && \
        sed -i 's/http_access deny all/#http_access deny all/g' /etc/squid/squid.conf 

FROM builder as final
    COPY shell/ /tmp
    WORKDIR /tmp
    RUN \
        # alias
        cat alias.sh >> /root/.zshrc && \
        cp .tmux.conf /root

    WORKDIR /root