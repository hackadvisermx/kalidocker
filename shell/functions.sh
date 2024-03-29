
## >>> Bugbounty --------------------------------------------------------------------------------------------------------------- >
# [Fase 1] - Enumeracion de sudominios
get_subdomains() { 
	echo -e $redC"[Fase 1] - "$endC "Enumerarando los subdominios ... "
	findomain -t $1 -u subdomains_findomain.txt
	assetfinder --subs-only $1 > subdomains_assetfinder.txt
	amass enum -d $1 -passive -o subdomains_amass.txt
	subfinder -d $1 -silent -o subdomains_subfinder.txt
	sort -u subdomains_*.txt -o subdomains.txt
	cat subdomains.txt | rev | cut -d . -f 1-3 | rev | sort -u | tee sudomains_root.txt
	cat *.txt | sort -u > 1-subdomains.txt
	find . -type f -not -name '1-subdomains.txt' -delete
 }

# [Fase 2] - Obteniendo hosts vivos
get_alive() {
	echo -e $redC"[Fase 2] - "$endC "Obteniendo hosts vivos"
	cat 1-subdomains.txt| httprobe -c 50 -t 3000  > 2-subdomains-live.txt
}

# [Fase 3] - Obteniendo pantallas
get_screen() {
    echo -e $redC"[+]"$endC "Obteniendo capturas de pantalla (aquatone) "
    current_path=$(pwd)
    cat 2-subdomains-live.txt | aquatone -silent --ports xlarge -out $current_path/aquatone/ -scan-timeout 500 -screenshot-timeout 50000 -http-timeout 6000
}

# [Recon - All Phases]
recon() {
	folder=$1-$(date '-I')
	mkdir $folder && cd $folder
    get_subdomains $1 # Fase 1
    get_alive         # Fase 2
    get_screen        # Fase 3
}


# >>> Pentesting  --------------------------------------------------------------------------------------------------------------- >

## Monta servidor web en la carpeta actual
webserverhere() { python3 -m http.server 80 }


## Monta servidor smb en la carpeta actual
smbserverhere() {
    local sharename
    [[ -z $1 ]] && sharename="share" || sharename=$1
    impacket-smbserver -smb2support $sharename . -username tmp -password tmp 
}

## nmap

#### Escanea hosts, todos los puertos
nmapall() { nmap -sS --min-rate 5000 -vvv -n -Pn -p- -oG allports $1 }

#### Extraer puertos 
extractports() { 
	cat allports | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',' | tee ports
	cat allports | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1 | tee ip
}

#### Escanea hosts, puertos por defecto, ejecuta scripts, versiones de servicios
nmapserv() { 
	nmap -p$(cat ports) -sC -sV --min-rate 5000 -vvv -n -Pn -oN nmap $(cat ip)
}

#### todo nmap
nmp() {
	nmapall $1
	extractports
	nmapserv
	cat nmap
}