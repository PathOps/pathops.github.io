# WireGuard Migration -- PathOps Demo

## Overview

This document describes the migration from a DDNS + port-forwarding
based architecture to a WireGuard-based private network topology for the
PathOps demo environment.

### Goals

-   Remove dependency on dynamic home IP
-   Eliminate DDNS
-   Remove router port forwarding
-   Establish a secure private overlay network
-   Allow the droplet to directly access all LAN VMs

------------------------------------------------------------------------

# Architecture Before

Internet ↓ Droplet (Nginx) ↓ DDNS → Router → Port Forward → VM

Problems:

-   Depends on dynamic IP
-   Requires router configuration
-   NAT complexity
-   Harder debugging
-   Not production-like

------------------------------------------------------------------------

# Architecture After

Internet ↓ Droplet (Public IP) ↓ WireGuard (UDP 51820) ↓ Private Network
10.10.0.0/24 ↓ LAN VMs

No DDNS.\
No router port forwarding.\
No NAT traversal complexity.

------------------------------------------------------------------------

# Network Design

## WireGuard Network

10.10.0.0/24

  Node                     WireGuard IP
  ------------------------ --------------
  Droplet (Hub)            10.10.0.1
  vm01-edge                10.10.0.2
  vm02-gitlab              10.10.0.3
  vm03-jenkins             10.10.0.4
  vm04-k8s-shared          10.10.0.5
  vm05-k8s-control-plane   10.10.0.6
  vm06-k8s-apps            10.10.0.7

------------------------------------------------------------------------

# Step 1 -- Install WireGuard

On every node:

-   Droplet
-   All LAN VMs

``` bash
sudo apt update
sudo apt install -y wireguard
```

------------------------------------------------------------------------

# Step 2 -- Generate Keys

On each node:

``` bash
wg genkey | tee privatekey | wg pubkey > publickey
```

This produces:

-   privatekey
-   publickey

## Key Handling

-   Store privatekey in Ansible Vault
-   Store publickey in peer configuration
-   Remove local key files after copying to Ansible


------------------------------------------------------------------------

# Step 3 -- Update Droplet Reverse Proxy (Nginx)

Replace DDNS backend with WireGuard IP.

Before:

``` nginx
proxy_pass https://my-ddns-host;
```

After:

``` nginx
proxy_pass https://10.10.0.2:443;
```

Reload:

``` bash
sudo nginx -t
sudo systemctl reload nginx
```

------------------------------------------------------------------------

# Verification

On droplet:

``` bash
ping 10.10.0.2
nc -vz 10.10.0.3 22
```

On VM:

``` bash
ping 10.10.0.1
```

Check tunnel status:

``` bash
sudo wg
```

------------------------------------------------------------------------

# Final State

The droplet acts as:

-   Public ingress gateway
-   WireGuard hub
-   Reverse proxy
-   Git SSH TCP forwarder

LAN becomes:

-   Private
-   Fully isolated
-   Not publicly exposed
-   Independent of dynamic IP

------------------------------------------------------------------------

# Result

PathOps demo now runs on a production-like hybrid architecture:

-   Public cloud gateway
-   Private overlay network
-   Fully reproducible via Ansible
-   No router dependencies
-   No DDNS
-   Clean networking model