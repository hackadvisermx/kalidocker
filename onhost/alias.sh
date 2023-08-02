# clonar repo kalidocker
alias kdc="git clone https://github.com/hackadvisermx/kalidocker"

# permite construir la imagen del repo clonado
alias kdb="docker build -t hackadvisermx/kalidocker ."

# borrar imagen de kalidocker
alias kdd="docker rmi kalidocker"

# subir imagen al dockerhub
alias kdp="docker push hackadvisermx/kalidocker"

# pentest local
alias kdl="docker run --rm -it --name kalidocker -p 80:80  \ 
-v /home/tester/hackdata:hackdata hackadvisermx/kalidocker /bin/zsh"

# pentest vpn / proxy 
alias kdr="docker run --rm -it --name kalidocker -p 3128:3128 -p 80:80 -p8080-8090:8080-8090 --cap-add=NET_ADMIN --device=/dev/net/tun \
--sysctl net.ipv6.conf.all.disable_ipv6=0  -v /home/tester/vpn:/root/vpn -v /home/tester/hackdata:/root/hackdata hackadvisermx/kalidocker /bin/zsh"

# entrar a instancia de kalidocker 
alias kde="docker exec -it kalidocker /bin/zsh"
