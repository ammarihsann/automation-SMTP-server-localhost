# Setup Script for Mail and Roundcube Installation

This script automates the installation and configuration of Postfix, Dovecot, Thunderbird, MariaDB, and Roundcube on a Debian-based system.

## Features

- Adds specified hosts to `/etc/hosts`
- Adds IP addresses to Postfix `mynetworks`
- Installs and configures Postfix, Dovecot, and Thunderbird
- Installs and configures MariaDB
- Installs and configures Roundcube with custom settings
- Updates Apache configuration for Roundcube

## Requirements

- A Debian-based system
- Root privileges to run the script

## Usage

1. Save the script to a file, for example, `automation_mailserver.sh`.
2. Make the script executable:
    ```bash
    chmod +x automation_mailserver.sh
    ```
3. Run the script:
    ```bash
    ./automation_mailserver.sh
    ```

### Input Prompts

During the script execution, you will be prompted for:

- Hosts to add to `/etc/hosts` (e.g., `192.168.100.212 smofi.com smofi`)
- IP addresses to add to Postfix `mynetworks` (e.g., `192.168.100.0/24`)
- Domain for Roundcube configuration (e.g., `debian.smofi`)
- Server IP for Apache configuration (e.g., `192.168.100.81`)
