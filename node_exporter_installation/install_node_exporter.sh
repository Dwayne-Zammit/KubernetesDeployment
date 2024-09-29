expected_version="1.7.0"

# function to check if we need to install or update node exporter
check_if_node_exporter_needs_to_be_installed_or_updated() {
    # Define the expected Node Exporter version

    echo "Expected version: $expected_version"

    # Check if Node Exporter is installed and get its version
    if node_exporter_version=$(node_exporter --version 2>&1 | grep -oP 'version \K[0-9.]+'); then
        # Check if the installed version matches the expected version
        if [ "$node_exporter_version" = "$expected_version" ]; then
            echo "Node Exporter version is already installed version: $expected_version. Exiting..."
            return 0
        else
            echo "Node Exporter version does not match the expected version...."
            
            echo "Stopping node exporter to proceed with updating node exporter..."
            sudo systemctl stop node_exporter.service
            
            echo "Proceeding with node exporter installation ..."
            return 1
        fi
    else
        echo "Node Exporter is not installed. Proceeding with node exporter version $expected_verion installation..."
        return 1
    fi
}

# function to identify system architecture
identify_architecture() {
    # Identifying the Architecture
    local architecture="$(lscpu | grep Architecture |  awk '{print $2}')"

    if [[ ${architecture} == "aarch64" ]]; then
        echo "arm"
    else
        echo "amd"
    fi
}

create_node_exporter_user_and_group() {
    sudo groupadd -f node_exporter
    sudo useradd -g node_exporter --no-create-home --shell /bin/false node_exporter
}

clean_existing_node_exporter_directory() {
    if [ -d /etc/node_exporter ]; then
        echo ""
        echo "Node Exporter directory already exists. Deleting its contents to proceed with installation"
        sudo rm -r /etc/node_exporter/*
    else
        echo ""
        echo "Node Exporter directory does not exist. Creating..."
        sudo mkdir /etc/node_exporter
        sudo chown node_exporter:node_exporter /etc/node_exporter
        echo "Created"
    fi
}

setup_node_exporter_service_file() {
    local service_file_path="$1"
    sudo tee "$service_file_path" > /dev/null <<EOF
[Unit]
Description=Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
ExecStart=/usr/bin/node_exporter --web.listen-address=:9100 --collector.systemd --collector.processes

[Install]
WantedBy=multi-user.target
EOF
    # Assign permissions to the service
    sudo chmod 664 "$service_file_path"
    echo "Service has been set up successfully..."
    echo ""
}

check_node_exporter_service() {
    # Check if service is running
    if systemctl is-active --quiet "node_exporter.service"; then
        echo "Node Exporter is running"
    else
        echo "Node Exporter is not running. There might have been an error with the installation"
        exit 1
    fi
}

reload_and_start_node_exporter_service() {
    sudo systemctl daemon-reload
    sudo systemctl enable node_exporter
    sudo systemctl start node_exporter
	check_node_exporter_service
}

# function to install node exporter
install_node_exporter() {
    # Define variables
    url="https://github.com/prometheus/node_exporter/releases/download/v$expected_version/node_exporter-$expected_version.linux-${arch}64.tar.gz"
    node_exporter_files_dir="/etc/node_exporter/node_exporter-files"
    node_exporter_service_file="/etc/systemd/system/node_exporter.service"

    # Download Node Exporter
    sudo wget $url 2> /dev/null

    create_node_exporter_user_and_group
    clean_existing_node_exporter_directory

    # Unpack binaries
    sudo tar -xvf "node_exporter-${expected_version}.linux-${arch}64.tar.gz"
    sudo mv "node_exporter-${expected_version}.linux-${arch}64" "$node_exporter_files_dir"
    echo "-----------------------------------------------"
    echo "Installing node_exporter"

    # Copy binaries to /usr/bin/
    sudo cp "$node_exporter_files_dir/node_exporter" /usr/bin/
    sudo chown node_exporter:node_exporter /usr/bin/

    # Setup Node Exporter Service
    echo "----------------------------------------------"
    echo "Setting up node_exporter service"
    setup_node_exporter_service_file "$node_exporter_service_file"

    # Reload systemd and start the service
    reload_and_start_node_exporter_service

    # Clean up downloaded and temp files
    sudo rm -rf "node_exporter-${expected_version}.linux-${arch}64.tar.gz" "node_exporter-files"
}


# main 
check_if_node_exporter_needs_to_be_installed_or_updated
check_if_to_proceed_with_node_exporter_installation=$?
if [ $check_if_to_proceed_with_node_exporter_installation -eq 1 ]; then
        arch=$(identify_architecture)
        install_node_exporter
fi
                                                                                                                 