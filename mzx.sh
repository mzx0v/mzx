#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "{+}Usage: mzx [option]"
    echo "{+}run"
    echo "[!]==sudo mzx=="
    echo "{+}Options:"
    echo "  -h, --help        Show this help menu"
    echo "  -v                 version tool"
    echo "Description:"
    echo "  mzx is a pentesting tool for network scanning and information gathering."
    exit 0
fi

if [[ "$1" == "-v" ]]; then
    echo "mzx version 1.0"
    echo "Coming soon v2.0"
    exit 0
fi

#colors
RESET="\e[0m"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # Reset

pas=mzx

#Verify IP
function ip_test() {

    valid=false

    until $valid; do
        read -p $'\e[32mEnter the IP: \e[0m' ip_get

        if [[ $ip_get =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then

            IFS='.' read -r o1 o2 o3 o4 <<<"$ip_get"

            if ((o1 <= 255 && o2 <= 255 && o3 <= 255 && o4 <= 255)); then
                valid=true
            else
                echo -e "${RED}Invalid IP ❌ (range 0-255)${RESET}"
            fi

        else
            echo -e "${RED}Invalid format ❌${RESET}"
        fi
    done
}

port_test() {
    while true; do
        read -p "$(echo -e "${CYAN}Enter port(s): ${NC}")" po

        # تحقق: فقط أرقام + فاصلة + -
        if ! [[ "$po" =~ ^[0-9,-]+$ ]]; then
            echo -e "${RED}[!] Invalid format (use: 80 or 80,443 or 1-100)${NC}"
            continue
        fi

        # تحقق كل رقم داخل الرينج
        IFS=',' read -ra parts <<< "$po"

        valid=true

        for part in "${parts[@]}"; do
            # إذا رينج مثل 1-100
            if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                start=${BASH_REMATCH[1]}
                end=${BASH_REMATCH[2]}

                if (( start < 1 || end > 65535 || start > end )); then
                    valid=false
                    break
                fi

            # إذا رقم عادي
            elif [[ "$part" =~ ^[0-9]+$ ]]; then
                if (( part < 1 || part > 65535 )); then
                    valid=false
                    break
                fi

            else
                valid=false
                break
            fi
        done

        if ! $valid; then
            echo -e "${RED}[!] Port must be between 1-65535${NC}"
            continue
        fi

        break
    done
}
sys_update_menu() {
    echo -e "${YELLOW}========== System Update ==========${NC}"
    echo "1) Update package list"
    echo "2) Upgrade system"
    echo "3) Full upgrade"
    echo "4) Clean system"
    echo "5) Fix broken packages"
    echo "6) Show disk usage"
    echo "7) Back"
}

sys_update() {
    while true; do
        clear
        sys_update_menu
        read -p "$(echo -e "${BLUE}mzx>>> ${NC}")" choice

        case "$choice" in
            1)
                echo -e "${YELLOW}[!] Updating...${NC}"
                apt update
                ;;
            2)
                echo -e "${YELLOW}[!] Upgrading...${NC}"
                apt upgrade -y
                ;;
            3)
                echo -e "${YELLOW}[!] Full upgrade...${NC}"
                apt full-upgrade -y
                ;;
            4)
                echo -e "${YELLOW}[!] Cleaning...${NC}"
                apt autoremove -y && apt clean
                ;;
            5)
                echo -e "${YELLOW}[!] Fixing packages...${NC}"
                apt --fix-broken install
                ;;
            6)
                df -h
                ;;
            7)
                break
                ;;
            *)
                echo "Invalid option"
                ;;
        esac

        read -p "Press Enter to continue..."
    done
}
fu_exit(){
	echo -e "${CYAN}"
	echo "======================================"
	echo "   [✓] MZX SESSION TERMINATED"
	echo "--------------------------------------"
	echo "   Thanks for using mzx v1.0"
	echo "   Happy Pentesting 👾"
	echo "======================================"
	echo -e "${NC}"

	exit 0
}
#Verify the password

clear
echo ""
read -t 5 -s -p " Enter the password: " pass
if [ "$pass" == "$pas" ]; then
    echo "Password correct! ✅"
else
    echo "Password incorrect! ❌"
    exit 1
fi

#Check permissions

clear
if [ $EUID -ne 0 ]; then
    echo -e "${RED} شغل السكربت ك sudo ${RESET}"
    exit 1
fi

pause() {
    echo -e "${YELLOW}[*] Press Enter to continue...${NC}"
    read -r
    clear
}


menu_fa () {
    echo -e "${RED}"
    echo "███╗   ███╗███████╗██╗  ██╗"
    echo "████╗ ████║╚══███╔╝╚██╗██╔╝"
    echo "██╔████╔██║  ███╔╝  ╚███╔╝ "
    echo "██║╚██╔╝██║ ███╔╝   ██╔██╗ "
    echo "██║ ╚═╝ ██║███████╗██╔╝ ██╗"
    echo "╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝"
    echo -e "${RESET}"
    echo -e "${RED}============mzx==============${RESET}"
    echo -e "${RED}==Welcome to the mzx script==${RESET}"
    echo -e "${RED}=============================${RESET}"
    echo -e "${MAGENTA}|1- Network    "
    echo "|2- Information Gathering    "
    echo -e "|3- System update         "
    echo -e "========================== ${NC}"
}

network_fa() {

    echo -e "${YELLOW}=====================================${RESET}"
    echo -e "${GREEN}            NETWORK MENU             ${RESET}"
    echo -e "${YELLOW}=====================================${RESET}"

    echo -e "${CYAN}1- nmap"
    echo -e "${CYAN}2- Network system"
	echo -e "${CYAN}3- Back${RESET}"

    echo -e "${YELLOW}{+}===================={+}${RESET}"
}

nmap_fa() {
    echo -e "${YELLOW}1-Full scan"
    echo -e "2-Service + version"
    echo -e "3-Aggressive "
    echo -e "4-Quick scan"
    echo -e "5-OS detection "
    echo -e "6-Stealth scan "
    echo -e "7-UDP scan"
    echo -e "8-Custom port"
    echo -e "9-Vuln scan "
    echo -e "10-Save result"
    echo -e "11- go back ${RESET}"
	echo -e "${RED}0- go back ${RESET}"
    echo -e "${YELLOW}{+}===================={+}${RESET}"
}

sys_info() {

	clear
	echo -e "${YELLOW}======================================${RESET}"
	echo -e "${YELLOW}               Network Info                  ${RESET}"
	echo -e "${YELLOW}======================================${RESET}"
	ip a
	echo -e "${YELLOW}======================================${RESET}"
	ip r 
	echo -e "${YELLOW}======================================${RESET}"
	ip link
	echo -e "${YELLOW}======================================${RESET}"
	ss -tuln
	echo -e "${YELLOW}======================================${RESET}"
	echo -e "${YELLOW}            System Info             ${RESET}"
	echo -e "${YELLOW}======================================${RESET}"
	uname -a
	echo -e "${YELLOW}======================================${RESET}"
	whoami
	echo -e "${YELLOW}======================================${RESET}"
	id
	echo -e "${YELLOW}======================================${RESET}"
	uptime
	echo -e "${YELLOW}======================================${RESET}"
	echo -e "${YELLOW}            Processes             ${RESET}"
	echo -e "${YELLOW}======================================${RESET}"
	ps aux --sort=-%mem | head
	echo -e "${YELLOW}======================================${RESET}"
	echo -e "${YELLOW}            Storage              ${RESET}"
	echo -e "${YELLOW}======================================${RESET}"
	df -h
	echo -e "${YELLOW}======================================${RESET}"
	last | head
	echo -e "${YELLOW}======================================${RESET}"
	mount
	echo -e "${YELLOW}======================================${RESET}"
	echo -e "${YELLOW}             Users              ${RESET}"
	echo -e "${YELLOW}======================================${RESET}"
	who
	echo -e "${YELLOW}======================================${RESET}"
	last 
	echo -e "${YELLOW}======================================${RESET}"
	cut -d: -f1 /etc/passwd
	echo "==========================================="
	read -p "[*] Press Enter to continue..."
}

Information_fa() {

    
    clear
    echo -e "${YELLOW}======================================${RESET}"
    echo -e "${YELLOW}       INFORMATION GATHERING          ${RESET}"
    echo -e "${YELLOW}======================================${RESET}"

    read -p "[?] Enter Domain (e.g., google.com): " target_domain

    if [ -z "$target_domain" ]; then
        echo -e "${RED}[!] Error: Domain cannot be empty!${RESET}"
        sleep 1
        clear
        return
    fi

    echo -e "\n${BLUE}[*] Scanning: $target_domain ...${RESET}"

    {
        echo "-------------------------------------------"
        echo "Scan Date: $(date)"
        echo "Target: $target_domain"
        echo "-------------------------------------------"

        echo -e "\n[+] WHOIS Results:"
        whois "$target_domain"

        echo -e "\n[+] NSLOOKUP Results:"
        nslookup "$target_domain"

        echo -e "\n[+] DIG (DNS) Results:"
        dig "$target_domain" ANY

        echo -e "\n===========================================\n"
    } >>InformationGathering.txt 2>&1

        echo -e "${GREEN}[V] Done! Data saved to InformationGathering.txt${RESET}"
        echo -e "${YELLOW}======================================${RESET}"
        read -p "[*] Press Enter to return to Menu..."
        clear
    
}


# قسم التنفيذ 
while true; do
    clear
    menu_fa
    read -p "$(echo -e "${BLUE}mzx>>> : ${NC}")" nu

    case "$nu" in
        1)
            clear
            network_fa
            read -p "$(echo -e "${BLUE}mzx>>> : ${NC}")" ne_input

            case "$ne_input" in
                1)
                    ip_test

                    while true; do
                        clear
                        nmap_fa
                        read -p "$(echo -e "${BLUE}mzx>>> : ${NC}")" nm_input

                        case "$nm_input" in
                            1)
                                clear
                                echo -e "${YELLOW}==================="
                                echo -e "[!] Please wait..."
                                echo -e "===================${RESET}"
                                nmap -p- -T4 "$ip_get"
                                pause
                                ;;
                            2)
                                echo -e "${YELLOW}==================="
                                echo -e "[!] Please wait..."
                                echo -e "===================${RESET}"
                                nmap -sV -sC "$ip_get"
                                pause
                                ;;
                            3)
                                clear
                                echo -e "${YELLOW}==================="
                                echo -e "[!] Please wait..."
                                echo -e "===================${RESET}"
                                nmap -A "$ip_get"
								pause
                                ;;
                            4)
                                clear
                                echo -e "${YELLOW}==================="
                                echo -e "[!] Please wait..."
                                echo -e "===================${RESET}"
                                sudo nmap -F "$ip_get"
								pause
                                ;;
                            5)
                                clear
                                echo -e "${YELLOW}==================="
                                echo -e "[!] Please wait..."
                                echo -e "===================${RESET}"
                                sudo nmap -O "$ip_get"
								pause
                                ;;
                            6)
                                clear
                                echo -e "${YELLOW}==================="
                                echo -e "[!] Please wait..."
                                echo -e "===================${RESET}"
                                sudo nmap -sS "$ip_get"
								pause
                                ;;
                            7)
                                clear
                                echo -e "${YELLOW}==================="
                                echo -e "[!] Please wait..."
                                echo -e "===================${RESET}"
                                sudo nmap -sU "$ip_get"
								pause
                                ;;
                            8)
                                clear
								port_test
                                echo -e "${YELLOW}==================="
                                echo -e "[!] Please wait..."
                                echo -e "===================${RESET}"
                                sudo nmap -p "$po" "$ip_get"
								pause
                                ;;
                            9)
                                clear
                                echo -e "${YELLOW}==================="
                                echo -e "[!] Please wait..."
                                echo -e "===================${RESET}"
                                sudo nmap --script vuln "$ip_get"
								pause
                                ;;
                            10)
                                clear
                                echo -e "${YELLOW}==================="
                                echo -e "[!] Please wait..."
                                echo -e "===================${RESET}"
                                sudo nmap -A -oN nmap_scan.txt "$ip_get"
								pause
                                ;;
                            11)
                                break
                                ;;
							0)
								fu_exit
								;;
                            *)
                                echo "الرقم غلط"
                                ;;
                        esac
                    done
                    ;;
				2)
					sys_info
					;;
				3)
					clear
					return 
					;;
				
            esac
            ;;
        2)
            clear
            Information_fa
            read -p "" sdv
            ;;
		3)
			sys_update
			;;
    esac
done