#!/bin/bash

# ============================================
# Docker Container Manager
# Version: 2.0 - Pure Docker Edition
# Author: SDGAMER
# ============================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ASCII Art Banner
print_banner() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${CYAN}    ____             _               ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${CYAN}   │  _ \  ___   ___│ │ ___  _ __    ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${CYAN}   │ | | │/ _ \ / __│ │/ _ \│ '__│   ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${CYAN}   │ |_│ │ (_) │ (__│ │ (_) ││       ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${CYAN}   │____/ \___/ \___│_|\___/│_│       ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${WHITE}            Docker Container Manager              ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${YELLOW}                  Pure Docker Edition                  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Function to print header
print_header() {
    print_banner
    print_color "$CYAN" "════════════════════════════════════════════════════════════"
    print_color "$WHITE" "                         $1"
    print_color "$CYAN" "════════════════════════════════════════════════════════════"
    echo ""
}

# Progress bar function
show_progress() {
    local pid=$1
    local msg=$2
    local delay=0.1
    local spinstr='|/-\'
    
    print_color "$CYAN" "$msg"
    printf "["
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "%c" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b"
    done
    
    printf "\b] "
    print_color "$GREEN" "✓"
}

# Enhanced Docker image database
declare -A DOCKER_IMAGES=(
    ["1"]="ubuntu:22.04|Ubuntu 22.04 Jammy|LTS, Stable"
    ["2"]="ubuntu:24.04|Ubuntu 24.04 Noble|Latest LTS"
    ["3"]="debian:12|Debian 12 Bookworm|Stable"
    ["4"]="debian:11|Debian 11 Bullseye|Old Stable"
    ["5"]="centos:9|CentOS Stream 9|Enterprise"
    ["6"]="rockylinux:9|Rocky Linux 9|RHEL Compatible"
    ["7"]="almalinux:9|AlmaLinux 9|RHEL Fork"
    ["8"]="fedora:40|Fedora 40|Latest Features"
    ["9"]="archlinux:latest|Arch Linux|Rolling Release"
    ["10"]="alpine:latest|Alpine Linux|Lightweight (5MB)"
    ["11"]="oraclelinux:9|Oracle Linux 9|Enterprise"
    ["12"]="amazonlinux:2023|Amazon Linux 2023|AWS Optimized"
    ["13"]="nginx:latest|Nginx Web Server|Production Ready"
    ["14"]="httpd:latest|Apache HTTP Server|Web Server"
    ["15"]="mysql:8.0|MySQL 8.0|Database"
    ["16"]="postgres:16|PostgreSQL 16|Database"
    ["17"]="redis:latest|Redis|In-memory Database"
    ["18"]="node:20|Node.js 20|JavaScript Runtime"
    ["19"]="python:3.12|Python 3.12|Programming Language"
    ["20"]="golang:1.21|Go 1.21|Programming Language"
    ["21"]="php:8.2|PHP 8.2|Web Development"
    ["22"]="java:21|Java 21 OpenJDK|JVM Language"
    ["23"]="ruby:3.2|Ruby 3.2|Programming Language"
    ["24"]="wordpress:latest|WordPress|CMS"
    ["25"]="jenkins/jenkins:lts|Jenkins|CI/CD"
    ["26"]="gitlab/gitlab-ce:latest|GitLab CE|DevOps Platform"
    ["27"]="portainer/portainer-ce|Portainer CE|Docker Management UI"
    ["28"]="traefik:latest|Traefik|Reverse Proxy"
    ["29"]="grafana/grafana:latest|Grafana|Monitoring"
    ["30"]="prom/prometheus:latest|Prometheus|Monitoring"
)

# Network modes
declare -A NETWORK_MODES=(
    ["1"]="bridge|Default bridge network"
    ["2"]="host|Share host's network namespace"
    ["3"]="none|No networking"
    ["4"]="container:NAME|Share network with another container"
)

# Volume types
declare -A VOLUME_TYPES=(
    ["1"]="volume|Docker managed volume"
    ["2"]="bind|Bind mount (host directory)"
    ["3"]="tmpfs|Temporary filesystem (RAM)"
)

# Restart policies
declare -A RESTART_POLICIES=(
    ["1"]="no|Do not automatically restart"
    ["2"]="always|Always restart"
    ["3"]="on-failure|Restart on failure"
    ["4"]="unless-stopped|Restart unless explicitly stopped"
)

# Check Docker installation
check_docker_installation() {
    print_color "$CYAN" "🔍 Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_color "$RED" "❌ Docker is not installed!"
        echo ""
        print_color "$YELLOW" "📦 Would you like to install Docker now?"
        read -p "   Install Docker? (Y/n): " install_choice
        
        if [[ "$install_choice" =~ ^[Yy]?$ ]]; then
            install_docker
        else
            print_color "$RED" "❌ Docker is required for this script!"
            exit 1
        fi
    fi
    
    # Check Docker daemon
    if ! docker info &> /dev/null; then
        print_color "$RED" "❌ Docker daemon is not running!"
        echo ""
        print_color "$YELLOW" "💡 Try starting Docker:"
        echo "   sudo systemctl start docker"
        echo "   sudo systemctl enable docker"
        exit 1
    fi
    
    print_color "$GREEN" "✅ Docker is installed and running!"
    echo ""
}

# Install Docker
install_docker() {
    print_header "📦 Installing Docker"
    
    # Detect distribution
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME=$ID
    else
        print_color "$RED" "❌ Cannot detect OS distribution!"
        exit 1
    fi
    
    print_color "$BLUE" "📊 Detected: $PRETTY_NAME"
    echo ""
    
    case $OS_NAME in
        ubuntu|debian|linuxmint|pop)
            install_docker_debian
            ;;
        fedora|centos|rhel|rocky|almalinux)
            install_docker_rhel
            ;;
        arch|manjaro)
            install_docker_arch
            ;;
        *)
            print_color "$RED" "❌ Unsupported OS: $OS_NAME"
            show_docker_manual_install
            ;;
    esac
}

# Install Docker on Debian-based systems
install_docker_debian() {
    print_color "$GREEN" "📦 Installing Docker on Debian-based system..."
    echo ""
    
    # Remove old versions
    print_color "$CYAN" "🧹 Removing old Docker versions..."
    sudo apt-get remove -y docker docker-engine docker.io containerd runc
    
    # Update packages
    print_color "$CYAN" "🔄 Updating package lists..."
    sudo apt-get update
    
    # Install dependencies
    print_color "$CYAN" "📦 Installing dependencies..."
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker GPG key
    print_color "$CYAN" "🔑 Adding Docker GPG key..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    print_color "$CYAN" "📦 Adding Docker repository..."
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    print_color "$CYAN" "📥 Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add user to docker group
    print_color "$CYAN" "👤 Adding user to docker group..."
    sudo usermod -aG docker $USER
    
    print_color "$GREEN" "✅ Docker installed successfully!"
    echo ""
    print_color "$YELLOW" "⚠️  IMPORTANT: Log out and log back in for group changes to take effect!"
    echo ""
    
    read -p "📝 Press Enter to continue..."
}

# Install Docker on RHEL-based systems
install_docker_rhel() {
    print_color "$GREEN" "📦 Installing Docker on RHEL-based system..."
    echo ""
    
    # Remove old versions
    print_color "$CYAN" "🧹 Removing old Docker versions..."
    sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
    
    # Install dependencies
    print_color "$CYAN" "📦 Installing dependencies..."
    sudo yum install -y yum-utils
    
    # Add Docker repository
    print_color "$CYAN" "📦 Adding Docker repository..."
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    # Install Docker
    print_color "$CYAN" "📥 Installing Docker..."
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Start and enable Docker
    print_color "$CYAN" "▶️ Starting Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Add user to docker group
    print_color "$CYAN" "👤 Adding user to docker group..."
    sudo usermod -aG docker $USER
    
    print_color "$GREEN" "✅ Docker installed successfully!"
    echo ""
    print_color "$YELLOW" "⚠️  IMPORTANT: Log out and log back in for group changes to take effect!"
    echo ""
    
    read -p "📝 Press Enter to continue..."
}

# Show system information
show_system_info() {
    print_header "📊 System Information"
    
    print_color "$YELLOW" "🐳 Docker Information:"
    echo "──────────────────────────────────────"
    if command -v docker &> /dev/null; then
        echo -n "📦 Docker Version: "
        docker --version
        
        echo -n "📦 Docker Compose: "
        if command -v docker-compose &> /dev/null; then
            docker-compose --version
        elif docker compose version &> /dev/null; then
            docker compose version
        else
            echo "Not installed"
        fi
        
        # Container statistics
        local total_containers=$(docker ps -a -q | wc -l)
        local running_containers=$(docker ps -q | wc -l)
        echo "📦 Containers: $running_containers running, $total_containers total"
        
        # Image statistics
        local total_images=$(docker images -q | wc -l)
        echo "📷 Images: $total_images"
        
        # Volume statistics
        local total_volumes=$(docker volume ls -q | wc -l)
        echo "💾 Volumes: $total_volumes"
        
        # Network statistics
        local total_networks=$(docker network ls -q | wc -l)
        echo "🌐 Networks: $total_networks"
    else
        echo "❌ Docker not installed"
    fi
    
    echo ""
    print_color "$YELLOW" "💻 System Information:"
    echo "──────────────────────────────────────"
    
    # OS info
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "🏷️  OS: $PRETTY_NAME"
    fi
    
    # Kernel
    echo "🐧 Kernel: $(uname -r)"
    
    # Resources
    echo "⚡ CPU: $(nproc) cores"
    echo "💾 RAM: $(free -h | awk '/^Mem:/ {print $2}') total"
    echo "💿 Disk: $(df -h / | awk 'NR==2 {print $4}') free"
    
    echo ""
    print_color "$CYAN" "🔧 Quick Commands:"
    echo "  docker ps -a                         # List all containers"
    echo "  docker images                        # List all images"
    echo "  docker volume ls                     # List all volumes"
    echo "  docker network ls                    # List all networks"
    echo "  docker stats                         # Show container stats"
    echo "  docker system df                     # Show Docker disk usage"
    
    read -p "⏎ Press Enter to continue..."
}

# Create Docker container
create_docker_container() {
    print_header "🚀 Create Docker Container"
    
    # Container name
    while true; do
        read -p "🏷️  Enter container name: " container_name
        
        if [[ -z "$container_name" ]]; then
            print_color "$RED" "❌ Container name cannot be empty!"
            continue
        fi
        
        # Check if container already exists
        if docker ps -a --format "{{.Names}}" | grep -q "^${container_name}$"; then
            print_color "$RED" "❌ Container '$container_name' already exists!"
            read -p "🔄 Use different name? (y/N): " rename_choice
            if [[ ! "$rename_choice" =~ ^[Yy]$ ]]; then
                return
            fi
            continue
        fi
        
        break
    done
    
    # Select image
    select_docker_image
    
    # Container configuration
    configure_docker_container "$container_name"
    
    # Build Docker command
    build_docker_command "$container_name"
    
    # Execute
    execute_docker_command "$container_name"
}

# Select Docker image
select_docker_image() {
    while true; do
        print_header "📦 Select Docker Image"
        
        # Categorized display
        print_color "$BLUE" "Operating Systems:"
        for key in {1..12}; do
            if [[ -n "${DOCKER_IMAGES[$key]}" ]]; then
                IFS='|' read -r image_name display_name description <<< "${DOCKER_IMAGES[$key]}"
                printf "  ${GREEN}%2d)${NC} %-25s ${CYAN}%-40s${NC}\n" "$key" "$display_name" "$description"
            fi
        done
        
        echo ""
        print_color "$BLUE" "Applications & Services:"
        for key in {13..30}; do
            if [[ -n "${DOCKER_IMAGES[$key]}" ]]; then
                IFS='|' read -r image_name display_name description <<< "${DOCKER_IMAGES[$key]}"
                printf "  ${GREEN}%2d)${NC} %-25s ${CYAN}%-40s${NC}\n" "$key" "$display_name" "$description"
            fi
        done
        
        echo ""
        print_color "$GREEN" "s) 🔍 Search Docker Hub"
        print_color "$GREEN" "c) 📝 Enter custom image"
        print_color "$RED"   "0) ↩️  Back to Main Menu"
        echo ""
        
        read -p "🎯 Select image (1-30) or option: " image_choice
        
        case $image_choice in
            0)
                return 1
                ;;
            s|S)
                search_docker_hub
                continue
                ;;
            c|C)
                read -p "📦 Enter custom Docker image (e.g., nginx:alpine): " custom_image
                if [[ -n "$custom_image" ]]; then
                    image_name="$custom_image"
                    display_name="Custom: $custom_image"
                    break
                fi
                ;;
            *)
                if [[ -n "${DOCKER_IMAGES[$image_choice]}" ]]; then
                    IFS='|' read -r image_name display_name description <<< "${DOCKER_IMAGES[$image_choice]}"
                    break
                else
                    print_color "$RED" "❌ Invalid selection!"
                    sleep 1
                fi
                ;;
        esac
    done
    return 0
}

# Search Docker Hub
search_docker_hub() {
    print_header "🔍 Search Docker Hub"
    
    read -p "🔎 Enter search term: " search_term
    if [[ -z "$search_term" ]]; then
        return
    fi
    
    print_color "$CYAN" "🔍 Searching Docker Hub for '$search_term'..."
    
    # Try to search using Docker Hub API
    local results_file="/tmp/docker_search_$$.json"
    
    # Note: Docker Hub API requires authentication for extensive searches
    # This is a simple implementation
    print_color "$YELLOW" "📡 Note: Limited search results without Docker Hub authentication"
    echo ""
    
    # Try to pull image list from local cache
    print_color "$BLUE" "📋 Local matches:"
    local found=0
    for key in "${!DOCKER_IMAGES[@]}"; do
        IFS='|' read -r img_name img_display img_desc <<< "${DOCKER_IMAGES[$key]}"
        if [[ "$img_name" =~ $search_term ]] || [[ "$img_display" =~ $search_term ]] || [[ "$img_desc" =~ $search_term ]]; then
            printf "  ${GREEN}%2d)${NC} %-25s ${CYAN}%-40s${NC}\n" "$key" "$img_display" "$img_desc"
            found=1
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        print_color "$YELLOW" "⚠️  No local matches found for '$search_term'"
    fi
    
    echo ""
    print_color "$YELLOW" "💡 Tip: You can use 'docker search $search_term' in terminal"
    echo "      Or visit: https://hub.docker.com/search?q=$search_term"
    
    read -p "⏎ Press Enter to continue..."
}

# Configure Docker container
configure_docker_container() {
    local container_name=$1
    
    print_header "⚙️  Container Configuration: $container_name"
    
    # Network configuration
    print_color "$YELLOW" "🌐 Network Configuration:"
    echo "  1) Bridge (Default) - Docker internal network"
    echo "  2) Host - Share host network stack"
    echo "  3) None - No networking"
    echo "  4) Custom network"
    read -p "Select network mode (1-4, default: 1): " network_choice
    
    case $network_choice in
        1) network_mode="bridge" ;;
        2) network_mode="host" ;;
        3) network_mode="none" ;;
        4)
            echo "Available networks:"
            docker network ls
            read -p "Enter network name: " custom_network
            network_mode="$custom_network"
            ;;
        *) network_mode="bridge" ;;
    esac
    
    # Port mappings
    echo ""
    print_color "$YELLOW" "🔌 Port Mappings:"
    echo "  Format: HOST_PORT:CONTAINER_PORT (e.g., 8080:80)"
    echo "  Multiple ports: 8080:80,443:443,2222:22"
    read -p "Port mappings (leave empty for none): " port_mappings
    
    # Volume mounts
    echo ""
    print_color "$YELLOW" "💾 Volume Mounts:"
    echo "  Format: /host/path:/container/path[:ro]"
    echo "  Example: /home/user/data:/app/data"
    echo "  Add :ro for read-only (e.g., /data:/app/data:ro)"
    read -p "Volume mounts (comma separated, leave empty for none): " volume_mounts
    
    # Environment variables
    echo ""
    print_color "$YELLOW" "🔧 Environment Variables:"
    echo "  Format: VAR=value"
    echo "  Multiple: VAR1=value1,VAR2=value2"
    read -p "Environment variables (comma separated): " env_vars
    
    # Resource limits
    echo ""
    print_color "$YELLOW" "📊 Resource Limits:"
    read -p "Memory limit (e.g., 512m, 2g, leave empty for unlimited): " memory_limit
    read -p "CPU limit (e.g., 1.5, 2, leave empty for unlimited): " cpu_limit
    read -p "CPU cores (e.g., 0-3, leave empty for all): " cpu_cores
    
    # Container options
    echo ""
    print_color "$YELLOW" "⚡ Container Options:"
    read -p "Restart policy (no, always, on-failure, unless-stopped): " restart_policy
    restart_policy=${restart_policy:-unless-stopped}
    
    read -p "Container command (override default, leave empty for default): " container_command
    
    # Security options
    echo ""
    print_color "$YELLOW" "🔒 Security Options:"
    read -p "Run as privileged container? (y/N): " privileged_choice
    read -p "Add capabilities (e.g., NET_ADMIN,SYS_ADMIN): " add_capabilities
    read -p "Drop capabilities (e.g., NET_RAW): " drop_capabilities
}

# Build Docker command
build_docker_command() {
    local container_name=$1
    
    # Start building command
    docker_cmd="docker run -d"
    docker_cmd+=" --name '$container_name'"
    
    # Network
    if [[ "$network_mode" != "bridge" ]]; then
        docker_cmd+=" --network '$network_mode'"
    fi
    
    # Port mappings
    if [[ -n "$port_mappings" ]]; then
        IFS=',' read -ra PORTS <<< "$port_mappings"
        for port in "${PORTS[@]}"; do
            docker_cmd+=" -p '$port'"
        done
    fi
    
    # Volume mounts
    if [[ -n "$volume_mounts" ]]; then
        IFS=',' read -ra VOLUMES <<< "$volume_mounts"
        for volume in "${VOLUMES[@]}"; do
            docker_cmd+=" -v '$volume'"
        done
    fi
    
    # Environment variables
    if [[ -n "$env_vars" ]]; then
        IFS=',' read -ra ENVS <<< "$env_vars"
        for env in "${ENVS[@]}"; do
            docker_cmd+=" -e '$env'"
        done
    fi
    
    # Resource limits
    if [[ -n "$memory_limit" ]]; then
        docker_cmd+=" --memory '$memory_limit'"
    fi
    
    if [[ -n "$cpu_li
