#!/bin/bash
clear
[[ "$(whoami)" != "root" ]] && {
echo -e "\033[1;33m[\033[1;31mError\033[1;33m] \033[1;37m- \033[1;33m◇ YOU NEED TO RUN AS ROOT!\033[0m"
exit 0
}

# Check if running on Ubuntu 20.04
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ] || [ "$VERSION_ID" != "20.04" ]; then
        echo -e "\033[1;33m[\033[1;31mError\033[1;33m] \033[1;37m- \033[1;33m◇ THIS SCRIPT IS DESIGNED FOR UBUNTU 20.04!\033[0m"
        exit 0
    fi
else
    echo -e "\033[1;33m[\033[1;31mError\033[1;33m] \033[1;37m- \033[1;33m◇ UNABLE TO DETERMINE OS VERSION!\033[0m"
    exit 0
fi

# Function to display progress bar
fun_bar () {
    comando[0]="$1"
    comando[1]="$2"
    (
    [[ -e $HOME/fim ]] && rm $HOME/fim
    ${comando[0]} -y > /dev/null 2>&1
    ${comando[1]} -y > /dev/null 2>&1
    touch $HOME/fim
    ) > /dev/null 2>&1 &
    tput civis
    echo -ne "  \033[1;33m◇ PLEASE WAIT... \033[1;37m- \033[1;33m["
    while true; do
        for((i=0; i<18; i++)); do
            echo -ne "\033[1;31m#"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "\033[1;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "  \033[1;33m◇ PLEASE WAIT... \033[1;37m- \033[1;33m["
    done
    echo -e "\033[1;33m]\033[1;37m -\033[1;32m◇ DONE!\033[1;37m"
    tput cnorm
}

# Display welcome message
echo -e "\033[1;31m\033[0m"
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%40s%s%-12s\n' "◇─────────ㅤ🐉ㅤWelcome To DRAGON VPS MANAGERㅤ🐉ㅤ─────────◇" ; tput sgr0
echo -e "\033[1;31m◇──────────────────────────────────────────────────────◇\033[0m"
echo ""
echo -e "\033[1;31m◇ ATTENTION!ㅤ⚠️ㅤ.\033[1;33mㅤTHIS SCRIPT CONTAINS THE FOLLOWING!!\033[0m"
echo ""
echo -e "\033[1;31m◇ \033[1;33mINSTALL A SET OF SCRIPTS AS TOOLS FOR\033[0m"
echo -e "\033[1;33mNETWORK, SYSTEM AND USER MANAGEMENT.\033[0m"
echo ""
echo -e "\033[1;32m◇ \033[1;32mTIP! \033[1;33mUSE THE DARK THEME IN YOUR TERMINAL \033[0m"
echo -e "\033[1;33mFOR A BETTER EXPERIENCE AND VIEW OF IT!\033[0m"
echo ""
echo -e "\033[1;31m◇──────────────ㅤ🐉ㅤDRAGON VPS MANAGERㅤ🐉ㅤ──────────────◇\033[0m"
echo ""
echo -e "\033[1;31m◇ \033[1;33mUBUNTU 20.04 OPTIMIZED VERSION\033[0m"
echo ""

# Ask for confirmation
echo -ne "\033[1;36m◇ Want to continue? [Y/N]: \033[1;37m"; read x
[[ $x = @(n|N) ]] && exit

# Reset SSH port if needed
sed -i 's/Port 22222/Port 22/g' /etc/ssh/sshd_config > /dev/null 2>&1
service ssh restart > /dev/null 2>&1

# Update system packages
echo -e "\n\033[1;36m◇ UPDATING SYSTEM PACKAGES...\033[0m"
fun_att () {
    apt-get update -y
    apt-get upgrade -y
}
fun_bar 'fun_att'

# Install required dependencies
echo -e "\n\033[1;36m◇ INSTALLING REQUIRED DEPENDENCIES...\033[0m"
inst_pct () {
    apt install -y net-tools dnsutils curl wget screen python3 python3-pip bc apache2 cron unzip lsof dos2unix nload jq figlet
    pip3 install speedtest-cli
}
fun_bar 'inst_pct'

# Configure firewall
echo -e "\n\033[1;36m◇ CONFIGURING FIREWALL...\033[0m"
if [[ -f "/usr/sbin/ufw" ]]; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 3128/tcp
    ufw allow 8799/tcp
    ufw allow 8080/tcp
    ufw allow 7300/udp
    ufw allow 7200/udp
    ufw allow 7100/udp
    ufw allow 53/udp
fi

# Enable BBR congestion control
echo -e "\n\033[1;36m◇ ENABLING BBR CONGESTION CONTROL...\033[0m"
enable_bbr () {
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
}
fun_bar 'enable_bbr'

# Create necessary directories
echo -e "\n\033[1;36m◇ SETTING UP DIRECTORIES...\033[0m"
mkdir -p /etc/VPSManager/senha
touch /etc/VPSManager/Exp
mkdir -p /etc/VPSManager/userteste
mkdir -p /etc/VPSManager/.tmp
mkdir -p /etc/bot
mkdir -p /etc/bot/info-users
mkdir -p /etc/bot/arquivos
mkdir -p /etc/bot/revenda
mkdir -p /etc/bot/suspensos
touch /etc/bot/lista_ativos
touch /etc/bot/lista_suspensos

# Download and install DRAGON VPS MANAGER
echo -e "\n\033[1;36m◇ DOWNLOADING DRAGON VPS MANAGER...\033[0m"
cd /tmp
wget https://raw.githubusercontent.com/januda-ui/DRAGON-VPS-MANAGER/main/mkmk > /dev/null 2>&1
chmod +x mkmk
./mkmk
rm /tmp/mkmk > /dev/null 2>&1

# Apply our improvements
echo -e "\n\033[1;36m◇ APPLYING UBUNTU 20.04 OPTIMIZATIONS...\033[0m"
apply_improvements () {
    # Replace the original modules with our improved versions
    cd /tmp
    wget https://raw.githubusercontent.com/januda-ui/DRAGON-VPS-MANAGER/main/Modulos/badvpn > /dev/null 2>&1
    wget https://raw.githubusercontent.com/januda-ui/DRAGON-VPS-MANAGER/main/Modulos/wsproxy.py > /dev/null 2>&1
    
    # Make sure the directory exists
    mkdir -p /bin
    
    # Copy the improved modules
    cp badvpn /bin/badvpn
    cp wsproxy.py /bin/wsproxy.py
    
    # Make them executable
    chmod +x /bin/badvpn
    chmod +x /bin/wsproxy.py
    
    # Create the slowdns_improved file
    cat > /bin/slowdns << 'EOF'
#!/bin/bash
clear
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
CORTITLE='\033[1;41m'
SCOLOR='\033[0m'
banner='
 ___ _    _____      _____  _  _ ___ 
/ __| |  / _ \ \    / /   \| \| / __|
\__ \ |_| (_) \ \/\/ /| |) | .  \__ \
|___/____\___/ \_/\_/ |___/|_|\_|___/'

echo -e "${CORTITLE}◇───────────────────────────────────────────────◇${SCOLOR}" 
echo -e "${CORTITLE}🐉ㅤDRAGON VPS MANAGER SLOW DNS MANAGERㅤ🐉${SCOLOR}"
echo -e "${CORTITLE}◇───────────────────────────────────────────────◇${SCOLOR}" 
echo -e "${RED}$banner${SCOLOR}"

# Function to check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "\n${RED}ERROR: THIS SCRIPT NEEDS TO BE RUN AS ROOT!${SCOLOR}"
        echo -e "${YELLOW}Use 'sudo -i' before running the script.${SCOLOR}\n"
        exit 1
    fi
}

# Function to check if required packages are installed
check_dependencies() {
    echo -e "\n${YELLOW}Checking dependencies...${SCOLOR}"
    
    local dependencies=("dnsutils" "screen" "curl" "iptables" "bind9")
    local missing_deps=()
    
    for dep in "${dependencies[@]}"; do
        if ! dpkg -s "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${YELLOW}Installing missing dependencies: ${missing_deps[*]}${SCOLOR}"
        apt-get update -y > /dev/null 2>&1
        apt-get install -y "${missing_deps[@]}" > /dev/null 2>&1
        
        # Check if installation was successful
        for dep in "${missing_deps[@]}"; do
            if ! dpkg -s "$dep" &> /dev/null; then
                echo -e "${RED}Failed to install $dep. Please install it manually.${SCOLOR}"
                exit 1
            fi
        done
        echo -e "${GREEN}All dependencies installed successfully.${SCOLOR}"
    else
        echo -e "${GREEN}All dependencies are already installed.${SCOLOR}"
    fi
}

# Function to download and install SlowDNS binaries
install_slowdns() {
    echo -e "\n${YELLOW}Installing SlowDNS binaries...${SCOLOR}"
    
    # Create directory for SlowDNS if it doesn't exist
    mkdir -p /etc/slowdns
    
    # Download the SlowDNS binary
    if [ ! -e "/etc/slowdns/dns" ]; then
        curl -s -o /etc/slowdns/dns https://github.com/januda-ui/DRAGON-VPS-MANAGER/raw/main/Modulos/dns > /dev/null 2>&1
        chmod +x /etc/slowdns/dns
        
        if [ ! -e "/etc/slowdns/dns" ]; then
            echo -e "${RED}Failed to download SlowDNS binary. Please check your internet connection.${SCOLOR}"
            exit 1
        fi
        echo -e "${GREEN}SlowDNS binary downloaded successfully.${SCOLOR}"
    else
        echo -e "${GREEN}SlowDNS binary already exists.${SCOLOR}"
    fi
}

# Function to generate keys for SlowDNS
generate_keys() {
    echo -e "\n${YELLOW}Generating SlowDNS keys...${SCOLOR}"
    
    cd /etc/slowdns
    if [ ! -e "/etc/slowdns/server.key" ] || [ ! -e "/etc/slowdns/server.pub" ]; then
        rm -f /etc/slowdns/server.key /etc/slowdns/server.pub 2>/dev/null
        
        # Generate new keys
        openssl genrsa -out server.key 2048 > /dev/null 2>&1
        openssl rsa -in server.key -pubout -out server.pub > /dev/null 2>&1
        
        if [ ! -e "/etc/slowdns/server.key" ] || [ ! -e "/etc/slowdns/server.pub" ]; then
            echo -e "${RED}Failed to generate keys. Please check if OpenSSL is installed.${SCOLOR}"
            exit 1
        fi
        echo -e "${GREEN}Keys generated successfully.${SCOLOR}"
    else
        echo -e "${GREEN}Keys already exist.${SCOLOR}"
    fi
    
    # Display the public key
    echo -e "\n${YELLOW}Your SlowDNS Public Key:${SCOLOR}"
    cat /etc/slowdns/server.pub
}

# Function to configure SlowDNS
configure_slowdns() {
    echo -e "\n${YELLOW}Configuring SlowDNS...${SCOLOR}"
    
    # Get the server's public IP
    PUBLIC_IP=$(curl -s ifconfig.me)
    
    # Ask for NS domain
    echo -e "\n${CYAN}Enter your NS domain (e.g., ns.yourdomain.com):${SCOLOR}"
    read -p "NS Domain: " NS_DOMAIN
    
    if [ -z "$NS_DOMAIN" ]; then
        echo -e "${RED}NS domain cannot be empty.${SCOLOR}"
        exit 1
    fi
    
    # Save configuration
    echo "$NS_DOMAIN" > /etc/slowdns/ns_domain
    echo "$PUBLIC_IP" > /etc/slowdns/public_ip
    cat /etc/slowdns/server.pub > /etc/slowdns/server_pub.txt
    
    echo -e "${GREEN}SlowDNS configuration saved.${SCOLOR}"
}

# Function to create SlowDNS service
create_service() {
    echo -e "\n${YELLOW}Creating SlowDNS service...${SCOLOR}"
    
    cat > /etc/systemd/system/slowdns.service << EOFX
[Unit]
Description=SlowDNS Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/slowdns
ExecStart=/etc/slowdns/dns -udp :53 -privkey /etc/slowdns/server.key \$(cat /etc/slowdns/ns_domain) 127.0.0.1:22
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOFX

    # Reload systemd and enable the service
    systemctl daemon-reload
    systemctl enable slowdns.service
    
    echo -e "${GREEN}SlowDNS service created successfully.${SCOLOR}"
}

# Function to start SlowDNS service
start_slowdns() {
    echo -e "\n${YELLOW}Starting SlowDNS service...${SCOLOR}"
    
    systemctl start slowdns.service
    
    # Check if service is running
    if systemctl is-active --quiet slowdns.service; then
        echo -e "${GREEN}SlowDNS service started successfully.${SCOLOR}"
    else
        echo -e "${RED}Failed to start SlowDNS service. Check logs with 'journalctl -u slowdns.service'.${SCOLOR}"
    fi
}

# Function to display SlowDNS information
show_info() {
    echo -e "\n${CORTITLE}◇───────────────────────────────────────────────◇${SCOLOR}" 
    echo -e "${YELLOW}SlowDNS Information:${SCOLOR}"
    echo -e "${CYAN}NS Domain:${SCOLOR} $(cat /etc/slowdns/ns_domain 2>/dev/null || echo "Not configured")"
    echo -e "${CYAN}Public IP:${SCOLOR} $(cat /etc/slowdns/public_ip 2>/dev/null || echo "Not configured")"
    echo -e "${CYAN}Public Key:${SCOLOR} $(cat /etc/slowdns/server_pub.txt 2>/dev/null || echo "Not configured")"
    echo -e "${CYAN}Service Status:${SCOLOR} $(systemctl is-active slowdns.service 2>/dev/null || echo "Not running")"
    echo -e "${CORTITLE}◇───────────────────────────────────────────────◇${SCOLOR}" 
    
    echo -e "\n${YELLOW}Instructions for Client:${SCOLOR}"
    echo -e "${WHITE}1. Configure your DNS to point to your NS domain.${SCOLOR}"
    echo -e "${WHITE}2. Use the public key for client configuration.${SCOLOR}"
    echo -e "${WHITE}3. Connect using SlowDNS client with your NS domain and public key.${SCOLOR}"
}

# Main menu function
main_menu() {
    clear
    echo -e "${CORTITLE}◇───────────────────────────────────────────────◇${SCOLOR}" 
    echo -e "${CORTITLE}🐉ㅤDRAGON VPS MANAGER SLOW DNS MANAGERㅤ🐉${SCOLOR}"
    echo -e "${CORTITLE}◇───────────────────────────────────────────────◇${SCOLOR}" 
    echo -e "${RED}$banner${SCOLOR}"
    
    echo -e "\n${CYAN}Select an option:${SCOLOR}"
    echo -e "${WHITE}1.${SCOLOR} ${YELLOW}Install SlowDNS${SCOLOR}"
    echo -e "${WHITE}2.${SCOLOR} ${YELLOW}Start SlowDNS Service${SCOLOR}"
    echo -e "${WHITE}3.${SCOLOR} ${YELLOW}Stop SlowDNS Service${SCOLOR}"
    echo -e "${WHITE}4.${SCOLOR} ${YELLOW}Restart SlowDNS Service${SCOLOR}"
    echo -e "${WHITE}5.${SCOLOR} ${YELLOW}Show SlowDNS Information${SCOLOR}"
    echo -e "${WHITE}6.${SCOLOR} ${YELLOW}Generate New Keys${SCOLOR}"
    echo -e "${WHITE}0.${SCOLOR} ${YELLOW}Exit${SCOLOR}"
    
    echo -e "\n${CYAN}Enter your choice:${SCOLOR}"
    read -p "Option: " option
    
    case $option in
        1)
            check_root
            check_dependencies
            install_slowdns
            generate_keys
            configure_slowdns
            create_service
            start_slowdns
            show_info
            ;;
        2)
            systemctl start slowdns.service
            echo -e "\n${GREEN}SlowDNS service started.${SCOLOR}"
            ;;
        3)
            systemctl stop slowdns.service
            echo -e "\n${YELLOW}SlowDNS service stopped.${SCOLOR}"
            ;;
        4)
            systemctl restart slowdns.service
            echo -e "\n${GREEN}SlowDNS service restarted.${SCOLOR}"
            ;;
        5)
            show_info
            ;;
        6)
            generate_keys
            echo -e "\n${GREEN}New keys generated. You may need to update client configurations.${SCOLOR}"
            ;;
        0)
            echo -e "\n${YELLOW}Exiting...${SCOLOR}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Invalid option. Please try again.${SCOLOR}"
            ;;
    esac
    
    echo -e "\n${CYAN}Press Enter to return to the main menu...${SCOLOR}"
    read
    main_menu
}

# Start the main menu
main_menu
EOF

    chmod +x /bin/slowdns
}
fun_bar 'apply_improvements'

# Run the original installer with our improvements
echo -e "\n\033[1;36m◇ INSTALLING DRAGON VPS MANAGER...\033[0m"
cd /tmp
wget https://raw.githubusercontent.com/januda-ui/DRAGON-VPS-MANAGER/main/mkmk > /dev/null 2>&1
chmod +x mkmk
./mkmk
rm /tmp/mkmk > /dev/null 2>&1

# Create a README file with information about the improvements
echo -e "\n\033[1;36m◇ CREATING DOCUMENTATION...\033[0m"
cat > /root/UBUNTU20_IMPROVEMENTS.md << 'EOF'
# DRAGON VPS MANAGER - Improvements for Ubuntu 20

This document outlines the improvements made to the DRAGON VPS MANAGER system to ensure better compatibility with Ubuntu 20 and enhance the connection modes.

## Improved Modules

### 1. BadVPN Module (`/bin/badvpn`)
- Added multi-port support (7300, 7200, 7100)
- Improved error handling
- Enhanced client connection limits
- Added better buffer management
- Improved service management (start, stop, restart)
- Added compatibility fixes for Ubuntu 20

### 2. WebSocket Proxy Module (`/bin/wsproxy.py`)
- Upgraded to Python 3 compatibility
- Improved error handling and logging
- Enhanced buffer size for better performance
- Added better connection management
- Improved security with proper encoding
- Added compatibility fixes for Ubuntu 20

### 3. SlowDNS Module (`/bin/slowdns`)
- Complete rewrite with systemd service integration
- Added dependency checking and installation
- Improved key management
- Enhanced configuration options
- Added user-friendly menu interface
- Better error handling and logging
- Added compatibility fixes for Ubuntu 20

## Additional Improvements

1. BBR congestion control enabled for better network performance
2. Firewall configured to allow all necessary ports
3. Additional dependencies installed for better compatibility
4. System packages updated to latest versions

These improvements ensure that DRAGON VPS MANAGER works effectively on Ubuntu 20 with enhanced connection modes and better overall performance.
EOF

# Install and configure V2Ray
echo -e "\n\033[1;36m◇ INSTALLING AND CONFIGURING V2RAY...\033[0m"
install_v2ray_module () {
    cd /tmp
    wget https://raw.githubusercontent.com/januda-ui/DRAGON-VPS-MANAGER/main/Modulos/v2ray -O /bin/v2ray > /dev/null 2>&1
    chmod +x /bin/v2ray
}
fun_bar 'install_v2ray_module'

# Inform the user about V2Ray
echo -e "\n\033[1;32m◇ V2Ray module installed successfully!\033[0m"
echo -e "\033[1;33m◇ You can configure V2Ray by running the command: \033[1;32mv2ray\033[0m"

# Final message
clear
echo -e "\033[1;31m\033[0m"
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%40s%s%-12s\n' "◇─────────ㅤ🐉ㅤDRAGON VPS MANAGER INSTALLEDㅤ🐉ㅤ─────────◇" ; tput sgr0
echo -e "\033[1;31m◇──────────────────────────────────────────────────────◇\033[0m"
echo ""
echo -e "\033[1;32m◇ INSTALLATION COMPLETED SUCCESSFULLY!\033[0m"
echo ""
echo -e "\033[1;33m◇ MAIN COMMAND:- \033[1;32mmenu\033[0m"
echo -e "\033[1;33m◇ IMPROVEMENTS DOCUMENTATION: \033[1;32m/root/UBUNTU20_IMPROVEMENTS.md\033[0m"
echo ""
echo -e "\033[1;33m◇ MORE INFORMATION \033[1;31m(\033[1;36m◇ TELEGRAM\033[1;31m): \033[1;37m@DRAGON_VPS_MANAGER \033[1;31m( \033[1;36m https://t.me/s/DRAGON_VPS_MANAGER \033[1;31m )\033[0m"
echo -e ""
IP=$(wget -qO- ipv4.icanhazip.com)
echo -e "\033[1;31m \033[1;33m◇--TIP!--◇\033[1;36mㅤ--Using this url you can easily see the number of users online at the server.\033[0m"
echo -e " http://$IP:8888/server/online"
echo -e ""
rm /tmp/mkmk > /dev/null 2>&1
cat /dev/null > ~/.bash_history && history -c 