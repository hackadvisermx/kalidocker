FROM kalilinux/kali-bleeding-edge as baseline

    RUN \
        apt update -y && \
        DEBIAN_FRONTEND="noninteractive" apt-get -y install  \
        amass \
        apache2 \
        apktool \
        assetfinder \
        binwalk \
        cewl \
        checksec \
        chisel \
        chromium \
        crackmapexec \
        curl \
        default-jdk \
        default-mysql-client \
        dirsearch \
        dnsenum \
        dnsrecon \
        dnsutils \
        enum4linux \
        evil-winrm \
        exiftool \
        exploitdb \
        foremost \
        fping \
        ftp \
        ffuf \
        gdb \
        gobuster \
        golang \
        hash-identifier \
        host \
        httprobe \
        httpx-toolkit \
        impacket-scripts \
        iputils-ping \
        knockpy \
        ltrace \
        openvpn \
        nano \
        nbtscan \
        net-tools \
        netcat-traditional \
        nmap \
        nuclei \
        metasploit-framework \
        pip \
        python3 \
        radare2 \
        seclists \
        smbclient \
        smbmap \
        snmp \
        steghide \
        socat \
        sqlite3 \
        sqlmap \
        sqsh \
        squid \
        strace \
        subfinder \
        sublist3r \
        tcpdump \
        telnet \
        tmux \
        unzip \
        wget \
        vim \
        webshells \
        winexe \
        whatweb \
        whois \
        wordlists \
        wpscan \
        zsh 

FROM baseline as builder 
    RUN \
        # Borra el mensaje por defecto de kali 
        touch /root/.hushlogin && \
         # Configuracion de Apache y Squid
	    sed -i 's/Si Funciona!/Funciona desde el contenedor!/g' /var/www/html/index.html && \
        echo "http_access allow all" >> /etc/squid/squid.conf && \
        sed -i 's/http_access deny all/#http_access deny all/g' /etc/squid/squid.conf && \
        # Instalar oh-my-zsh, sus plugins y configurarlo
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
        git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
        git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search /root/.oh-my-zsh/custom/plugins/zsh-history-substring-search && \
        git clone --depth 1 https://github.com/zsh-users/zsh-completions /root/.oh-my-zsh/custom/plugins/zsh-completions && \
        sed -i '1i export LC_CTYPE="C.UTF-8"' /root/.zshrc && \
        sed -i '2i export LC_ALL="C.UTF-8"' /root/.zshrc && \
        sed -i '3i export LANG="C.UTF-8"' /root/.zshrc && \
        sed -i '4i export LANGUAGE="C.UTF-8"' /root/.zshrc && \
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search zsh-completions)/g' /root/.zshrc && \
        sed -i '78i autoload -U compinit && compinit' /root/.zshrc && \
         # Ruta al archivo de historial del shell zsh para su persistencia
        sed -i '$a export HISTFILE="/root/vpn/.zsh_history"' /root/.zshrc 
        ENV PATH "$PATH:.:$GOPATH/bin:$GOROOT/bin"

FROM builder as builder1
    WORKDIR /tmp
    RUN \
        # aquetone 
        curl -sLO https://github.com/michenriksen/aquatone/releases/latest/download/aquatone_linux_amd64_1.7.0.zip  && \
        # finddomain
        curl -sLO https://github.com/Findomain/Findomain/releases/latest/download/findomain-linux.zip && \
        # gowitness
        curl -sLO https://github.com/sensepost/gowitness/releases/latest/download/gowitness-2.4.2-linux-amd64 && \
        # pspy
        curl -sLO https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64 && \ 
        # pwntools downlod
        pip3 install pwntools 

FROM builder1 as builder2
    WORKDIR /tmp
    RUN \
        # aquetone
        unzip aquatone_linux_amd64_1.7.0.zip && \
        mv aquatone /usr/local/bin && \
        # findomain install
        unzip findomain-linux.zip && \
        chmod +x findomain && \
        mv findomain /usr/local/bin && \
        # gowitness install
        chmod +x gowitness-2.4.2-linux-amd64 && \
        mv gowitness-2.4.2-linux-amd64 /usr/local/bin/gowitness && \
        # pspy
        mv pspy64 /usr/local/bin

FROM builder2 as builder3
    RUN \
    # uncover
    go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest

FROM builder3 as final
    COPY shell/ /tmp
    WORKDIR /tmp
    RUN \
        # alias, functionsß
        cat alias.sh >> /root/.zshrc && \
        cat functions.sh >> /root/.zshrc && \
        cp .tmux.conf /root && \
        rm -rf *
    WORKDIR /root