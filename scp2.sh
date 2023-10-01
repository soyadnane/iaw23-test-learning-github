#!/bin/bash

# Función para instalar una dependencia
function install_dependency() {
    local dependency=$1
    echo "Instalando $dependency..."
    sudo apt-get -qq install $dependency
}

# Verificar y, si es necesario, instalar ISC-DHCP
if ! dpkg -l | grep -q "isc-dhcp-server"; then
    install_dependency "isc-dhcp-server"
fi

# Verificar y, si es necesario, instalar ifconfig
if ! command -v ifconfig &>/dev/null; then
    install_dependency "net-tools"
fi

while true; do
    # Mostrar el menú principal
    opcion=$(dialog --menu "Menú DHCP" 15 50 6 \
        1 "Configurar servidor DHCP (dialog)" \
        2 "Ver estado del servicio" \
        3 "Gestionar servicio" \
        4 "Apagar interfaces" \
        5 "Salir" 3>&1 1>&2 2>&3)

    # Dependiendo de la opción seleccionada
    case $opcion in
        1)
            # Preguntar por la interfaz a configurar
            interfaz_a_configurar=$(dialog --menu "Selecciona la interfaz a configurar:" 10 40 2 \
                1 "enp0s3" \
                2 "enp0s8" 3>&1 1>&2 2>&3)

            case $interfaz_a_configurar in
                1)
                    # Configurar servidor DHCP para enp0s3 con dialog
                    dialog --title "Configuración DHCP (dialog)" --inputbox "Ingresa la dirección IP del servidor DHCP:" 10 40 2> /tmp/ip_servidor
                    ip_servidor=$(cat /tmp/ip_servidor)
                    
                    dialog --title "Configuración DHCP (dialog)" --inputbox "Ingresa la máscara de subred:" 10 40 2> /tmp/mascara_subred
                    mascara_subred=$(cat /tmp/mascara_subred)
                    
                    dialog --title "Configuración DHCP (dialog)" --inputbox "Ingresa la puerta de enlace (Gateway):" 10 40 2> /tmp/gateway
                    gateway=$(cat /tmp/gateway)

                    dialog --title "Configuración DHCP (dialog)" --inputbox "Ingresa el rango de direcciones IP a asignar (por ejemplo, 192.168.1.100 192.168.1.200):" 10 40 2> /tmp/rango_ip
                    rango_ip=$(cat /tmp/rango_ip)

                    # Configurar la interfaz enp0s3
                    dialog --title "Configuración DHCP (dialog)" --inputbox "Ingresa la dirección IP de la interfaz enp0s3:" 10 40 2> /tmp/ip_interfaz
                    ip_interfaz=$(cat /tmp/ip_interfaz)
                    
                    dialog --title "Configuración DHCP (dialog)" --inputbox "Ingresa la máscara de subred de la interfaz enp0s3:" 10 40 2> /tmp/mascara_interfaz
                    mascara_interfaz=$(cat /tmp/mascara_interfaz)

                    # Configurar el servidor DHCP
                    sudo sed -i '/^INTERFACESv4=/d' /etc/default/isc-dhcp-server
                    echo "INTERFACESv4=\"enp0s3\"" | sudo tee -a /etc/default/isc-dhcp-server
                    sudo service isc-dhcp-server restart
                    sudo ifconfig enp0s3 $ip_interfaz netmask $mascara_interfaz
                    sudo route add default gw $gateway

                    # Mostrar mensaje de configuración completa
                    dialog --title "Configuración DHCP" --msgbox "La configuración DHCP para enp0s3 se ha completado correctamente." 10 40
                    ;;
                2)
                    # Configurar servidor DHCP para enp0s8 con dialog
                    dialog --title "Configuración DHCP (dialog)" --inputbox "Ingresa la dirección IP del servidor DHCP:" 10 40 2> /tmp/ip_servidor
                    ip_servidor=$(cat /tmp/ip_servidor)
                    
                    dialog --title "Configuración DHCP (dialog)" --inputbox "Ingresa la máscara de subred:" 10 40 2> /tmp/mascara_subred
                    mascara_subred=$(cat /tmp/mascara_subred)
                    
                    dialog --title "Configuración DHCP (dialog)" --inputbox "Ingresa la puerta de enlace (Gateway):" 10 40 2> /tmp/gateway
                    gateway=$(cat /tmp/gateway)

                    dialog --title "Configuración DHCP (dialog)" --inputbox "Ingresa el rango de direcciones IP a asignar (por ejemplo, 192.168.2.100 192.168.2.200):" 10 40 2> /tmp/rango_ip
                    rango_ip=$(cat /tmp/rango_ip)

                    # Configurar la interfaz enp0s8
                    dialog --title "Configuración DHCP (dialog)" --inputbox "Ingresa la dirección IP de la interfaz enp0s8:" 10 40 2> /tmp/ip_interfaz
                    ip_interfaz=$(cat /tmp/ip_interfaz)
                    
                    dialog --title "Configuración DHCP (dialog)" --inputbox "Ingresa la máscara de subred de la interfaz enp0s8:" 10 40 2> /tmp/mascara_interfaz
                    mascara_interfaz=$(cat /tmp/mascara_interfaz)

                    # Configurar el servidor DHCP
                    sudo sed -i '/^INTERFACESv4=/d' /etc/default/isc-dhcp-server
                    echo "INTERFACESv4=\"enp0s8\"" | sudo tee -a /etc/default/isc-dhcp-server
                    sudo service isc-dhcp-server restart
                    sudo ifconfig enp0s8 $ip_interfaz netmask $mascara_interfaz
                    sudo route add default gw $gateway

                    # Mostrar mensaje de configuración completa
                    dialog --title "Configuración DHCP" --msgbox "La configuración DHCP para enp0s8 se ha completado correctamente." 10 40
                    ;;
            esac
            ;;
        2)
            # Mostrar un mensaje mientras se verifica el estado
            dialog --infobox "Verificando estado..." 10 40
            sleep 2

            # Verificar si el servicio está en ejecución
            if sudo systemctl is-active isc-dhcp-server; then
                dialog --title "Estado del servicio" --msgbox "El servicio DHCP está funcionando." 10 40
            else
                dialog --title "Estado del servicio" --msgbox "El servicio DHCP no está funcionando." 10 40
            fi
            ;;
        3)
            # Mostrar otro menú
            opcion_otro=$(dialog --menu "Selecciona un de las opciones" 10 40 3 \
                1 "Iniciar servicio DHCP" \
                2 "Apagar servicio DHCP" \
                3 "Reiniciar servicio DHCP" 3>&1 1>&2 2>&3)

            case $opcion_otro in
                1)
                    # Mostrar un mensaje mientras se inicia el servicio DHCP
                    dialog --infobox "Iniciando el servicio DHCP..." 10 40
                    sudo systemctl start isc-dhcp-server
                    sleep 2

                    # Mostrar mensaje de inicio completado
                    dialog --title "Iniciar servicio DHCP" --msgbox "El servicio DHCP se ha iniciado correctamente." 10 40
                    ;;
                2)
                    # Mostrar un mensaje mientras se apaga el servicio DHCP
                    dialog --infobox "Apagando el servicio DHCP..." 10 40
                    sudo systemctl stop isc-dhcp-server
                    sleep 2

                    # Mostrar mensaje de apagado completado
                    dialog --title "Apagar servicio DHCP" --msgbox "El servicio DHCP se ha apagado correctamente." 10 40
                    ;;
                3)
                    # Mostrar un mensaje mientras se reinicia el servicio DHCP
                    dialog --infobox "Reiniciando el servicio DHCP..." 10 40
                    sudo systemctl restart isc-dhcp-server
                    sleep 2

                    # Mostrar mensaje de reinicio completado
                    dialog --title "Reiniciar servicio DHCP" --msgbox "El servicio DHCP se ha reiniciado correctamente." 10 40
                    ;;
            esac
            ;;
        4)
            # Preguntar por la interfaz a apagar
            interfaz_a_apagar=$(dialog --menu "Selecciona la interfaz a apagar:" 10 40 2 \
                1 "enp0s3" \
                2 "enp0s8" 3>&1 1>&2 2>&3)

            case $interfaz_a_apagar in
                1)
                    interfaz="enp0s3"
                    ;;
                2)
                    interfaz="enp0s8"
                    ;;
            esac

            if [ -n "$interfaz" ]; then
                # Mostrar un mensaje mientras se apaga la interfaz especificada
                dialog --infobox "Apagando la interfaz $interfaz..." 10 40
                sudo ifconfig $interfaz down
                sleep 2

                # Mostrar mensaje de apagado completado
                dialog --title "Apagar interfaz $interfaz" --msgbox "La interfaz $interfaz se ha apagado correctamente." 10 40
            else
                # Mostrar mensaje de error si no se ingresó una interfaz válida
                dialog --title "Error" --msgbox "No se especificó una interfaz válida." 10 40
            fi
            ;;
        5)
            # Salir del script
            exit 0
            ;;
    esac
done