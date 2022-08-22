# 🌋 any-to-alpine

An Ansible role that converts any Linux server to Alpine Linux while preserving network configuration, SSH access, and some user settings. Probably not real-life usable but very satifying to watch how OS becomes Alpine in matter of minutes

## 🎥 Demo

[![Watch the video](https://i.ytimg.com/vi/goJBfm_-yF4/hqdefault.jpg?sqp=-oaymwEbCKgBEF5IVfKriqkDDggBFQAAiEIYAXABwAEG\u0026rs=AOn4CLCM7j5eW-mPSGEbtS4ErDjq)](https://youtu.be/goJBfm_-yF4)

## 🚀 What Does It Do?

This role transforms your running Linux system into Alpine Linux by:

1. **Capturing Current Configuration**: Reads your existing network settings (IPv4/IPv6), DNS configuration, SSH keys, and user information
2. **Building Alpine Image**: Creates a custom Alpine Linux image with all necessary packages and your configuration baked in
3. **Flashing the Disk**: Writes the new Alpine image directly to your system disk
4. **Automatic Reboot**: Forces an immediate reboot into the new Alpine system
5. **Reconnection**: Waits for Alpine to boot and automatically cleans up SSH known_hosts

## ⚙️ Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ata_img_size` | `386M` | Size of the Alpine image to create |
| `ata_hdd` | Required | Target disk device (e.g., `/dev/sda`) |
| `ata_image_path` | Optional | Path to pre-built Alpine image (skips building) |
| `ata_pkgs_to_add` | Optional | Additional Alpine packages to install |

## 🎯 Usage

### Basic Example

```yaml
---
- hosts: servers
  become: yes
  roles:
    - role: any-to-alpine
      vars:
        ata_hdd: /dev/sda
```

### With Additional Packages

```yaml
---
- hosts: servers
  become: yes
  roles:
    - role: any-to-alpine
      vars:
        ata_hdd: /dev/sda
        ata_img_size: 1G
        ata_pkgs_to_add:
          - docker
          - git
          - curl
```

### Using Pre-built Image

```yaml
---
- hosts: servers
  become: yes
  roles:
    - role: any-to-alpine
      vars:
        ata_hdd: /dev/sda
        ata_image_path: /path/to/custom-alpine.img
```

## ⚠️ Important Warnings

- **THIS WILL DESTROY ALL DATA** on the target disk
- Make sure you have backups before running
- Test in a VM or non-production environment first!!!
- The default password is set in the template (change immediately after first login)


## 📝 Customization Script

The role generates a `letsgoski.bash` script containing your system configuration. This script:
- Sets up network interfaces (IPv4 and IPv6)
- Configures DNS resolution
- Creates your user account
- Installs your SSH authorized keys
- Configures sudo access
- Sets up OpenRC services

A copy is saved to `/tmp/letsgoski-{{ inventory_hostname }}.bash` on your local machine for review.

## 🔗 Credits

Built on top of [alpine-make-vm-image](https://github.com/alpinelinux/alpine-make-vm-image) by Alpine Linux.

## 📜 License

This project inherits licensing from alpine-make-vm-image.

## 🤝 Contributing

Contributions welcome!