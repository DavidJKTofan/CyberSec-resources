#!/bin/bash 

ups_status() {
    curl localhost:3000;
}

restart_ups() {
    curl localhost:3000/restart;
}

list_processes() {
    ps -ef
}

list_ram() {
    free -h
}

list_connections() {
    netstat -plnt
}

list_storage() {
    df -h
}

welcome() {
    echo "[+] Welcome to Santa's Monitor Gadget!"
}

if [ "$#" -gt 0 ]; then
    $1
fi
