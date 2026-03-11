<!--
Copyright (c) 2026 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
Copyright (c) 2026 Luis Ruiz <luisan00@hotmail.com>

SPDX-License-Identifier: Apache-2.0
-->

# Roadmap

## Phase 1 - IEEE 802.15.4 radio

- Initialize the CC1312R sub-GHz radio driver
- Send and receive frames between two nodes
- Validate link range and stability

## Phase 2 - IPv6 networking over 802.15.4

- Configure the 802.15.4 network interface with IPv6
- Link-local address assignment
- Verify ping between two nodes over sub-GHz

## Phase 3 - PPP link between CC1312R and ESP32

- Configure UART between both SoCs
- Bring up PPP over UART
- Verify IPv6 connectivity between CC1312R and ESP32

## Phase 4 - WiFi on ESP32

- ESP32 firmware as coprocessor
- AP mode: allow mobile devices to connect to the node
- Client mode: connect the node to an existing WiFi network with internet access
- Route traffic between PPP and WiFi

## Phase 5 - AODVv2

- Implement route discovery (RREQ/RREP)
- Route maintenance (RERR, timeouts)
- Multi-hop routing between nodes
- Validate with 3+ nodes

## Phase 6 - Integration and gateway

- Gateway node: forward mesh traffic to the internet via WiFi
- Access mesh network services from mobile devices
- End-to-end testing
