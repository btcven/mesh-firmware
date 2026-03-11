<!--
Copyright (c) 2026 Luis Ruiz <luisan00@hotmail.com>
Copyright (c) 2026 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>

SPDX-License-Identifier: Apache-2.0
-->

# AODVv2 Research

## Overview

AODVv2 (Ad hoc On-Demand Distance Vector Routing version 2) is a reactive
routing protocol for mobile ad hoc networks (MANETs). It discovers routes
on-demand, meaning routes are only created when a node needs to send data to a
destination for which no route exists. This makes it well-suited for
resource-constrained devices where maintaining full topology state is not
feasible.

AODVv2 is the successor to AODV (RFC 3561) and was previously known as DYMO
(Dynamic MANET On-demand Routing).

## IETF draft status

AODVv2 has never been published as an RFC. It remains an expired Internet-Draft,
though the specification is considered stable enough to implement.

- **Last Working Group draft**: `draft-ietf-manet-aodvv2-16` (May 2016,
  expired November 2016)
- **Last individual draft**: `draft-perkins-manet-aodvv2-06` (June 2025,
  expired December 2025)
- **Authors**: Charles Perkins, John Dowdell, Lotte Steenbrink, Victoria
  Pritchard
- **Intended status**: Proposed Standard (never achieved)

The protocol has been in draft form since ~2013. After over a decade in the IETF
MANET working group, it has not achieved consensus for publication.

## Protocol description

### Message types

AODVv2 defines four message types, all encoded using the RFC 5444 Generalized
MANET Packet/Message Format (TLV encoding):

| Message      | Direction | Transport | Purpose |
|--------------|-----------|-----------|---------|
| **RREQ**     | Multicast | `ff02::6d` (LL-MANET-Routers) | Route Request: flooded to discover a route to a target |
| **RREP**     | Unicast   | Hop-by-hop | Route Reply: sent back from target to originator along the discovered path |
| **RERR**     | Unicast   | Hop-by-hop | Route Error: indicates a route to one or more destinations is broken |
| **RREP_Ack** | Unicast   | Hop-by-hop | Acknowledgement of RREP receipt for link bidirectionality check |

### Route discovery flow

1. Node A needs to send data to Node D but has no route.
2. Node A broadcasts a **RREQ** to `ff02::6d` (link-local multicast).
3. Intermediate nodes forward the RREQ, creating reverse route entries back to
   Node A.
4. When the RREQ reaches Node D (or a node with a valid route to D), it sends a
   **RREP** unicast back along the reverse path.
5. Each intermediate node receiving the RREP creates a forward route entry to
   Node D.
6. Node A can now send data to Node D.

### Route maintenance

- Routes have a **lifetime** that is refreshed each time the route is used.
- When a link break is detected (e.g., failed transmission), the detecting node
  sends a **RERR** to all affected upstream nodes.
- Nodes receiving a RERR invalidate the broken routes and may initiate new route
  discovery if needed.

### Route table entry structure

Each route entry contains (per the draft specification):

| Field              | Size (IPv6) | Description |
|--------------------|-------------|-------------|
| Address            | 16 bytes    | Destination IPv6 address |
| PrefixLength       | 1 byte      | Prefix length |
| SeqNum             | 2-4 bytes   | Sequence number for loop prevention |
| NextHop            | 16 bytes    | Next hop IPv6 address |
| NextHopInterface   | variable    | Network interface identifier |
| LastUsed           | 4 bytes     | Timestamp of last use |
| LastSeqNumUpdate   | 4 bytes     | Timestamp of last sequence number update |
| MetricType         | 1 byte      | Metric type (typically hop count) |
| Metric             | 1-2 bytes   | Route cost |
| State              | 1 byte      | Active / Idle / Invalid / Unconfirmed |

**Estimated size per entry**: ~50-64 bytes for IPv6 (dominated by the two
16-byte IPv6 addresses).

### RFC 5444 dependency

All AODVv2 messages use the Generalized MANET Packet/Message Format defined in
RFC 5444. This format uses Type-Length-Value (TLV) encoding for extensibility.
An RFC 5444 parser/serializer is a prerequisite for any AODVv2 implementation.

## Existing implementations

### RIOT OS / Locha Mesh (btcven)

The most directly relevant implementation. The Locha Mesh project (btcven)
previously implemented AODVv2 on RIOT OS targeting the same CC1312R hardware
with IEEE 802.15.4g sub-GHz radio and IPv6/6LoWPAN.

- Written in C, runs on RIOT's GNRC network stack
- Originally developed by Lotte Steenbrink (co-author of the IETF draft)
- Status: partially complete, not actively maintained
- Repository: [btcven/turpial-firmware](https://github.com/btcven/turpial-firmware)
- Original RIOT integration:
  [Lotterleben/RIOT-AODVv2](https://github.com/Lotterleben/RIOT-AODVv2)
- RIOT OS use case page:
  [riot-os.org/use_cases/locha](https://www.riot-os.org/use_cases/locha.html)

### Zephyr RTOS

No AODVv2 support exists in Zephyr. A PR for AODV routing in BLE Mesh
([#9210](https://github.com/zephyrproject-rtos/zephyr/pull/9210)) was rejected
in March 2019 because it violated the Bluetooth SIG Mesh Profile Specification.

Zephyr's mesh networking story is centered around Thread/OpenThread, which uses
its own MLE-based routing, not AODV.

### Other implementations

- **aodv-uu**: Linux user-space AODV v1 (RFC 3561), not AODVv2.
  [erimatnor/aodv-uu](https://github.com/erimatnor/aodv-uu)
- **ns-3 simulator**: An AODVv2 model was presented at the 2025 ns-3 workshop
  (C++, not portable to embedded).
- **ARM user-space**: A 2021 IEEE paper describes an AODVv2 user-space
  implementation cross-compiled for Raspberry Pi. Not suitable for bare-metal
  MCUs but could serve as a reference.

No standalone, portable C library for AODVv2 exists that could be dropped into
Zephyr.

## Resource requirements on CC1312R

The CC1312R has 80 KB RAM and 352 KB Flash.

### RAM

- At ~64 bytes per IPv6 route entry, 100 routes cost ~6.4 KB.
- The draft explicitly addresses memory-constrained devices: Active routes MUST
  NOT be expunged, Idle routes SHOULD NOT be, Invalid routes MAY be expunged
  (LRU order). This allows capping the route table size.
- Packet buffering during route discovery can be disabled entirely
  (`BUFFER_SIZE_PACKETS = 0`) to save RAM.
- The on-demand nature means the route table only contains routes that are
  actually in use, unlike proactive protocols that maintain full topology state.

### Flash

- A minimal AODVv2 implementation with RFC 5444 serialization is estimated at
  15-30 KB of Flash, well within the 352 KB budget.

## Integration with Zephyr

AODVv2 will be implemented as a local module within this repository, not
upstream in Zephyr.

### Proposed module structure

```
lib/aodvv2/
├── CMakeLists.txt        # zephyr_library() + sources
├── Kconfig               # CONFIG_AODVV2
├── include/aodvv2/       # public headers
└── src/
    ├── aodvv2.c          # protocol state machine
    ├── rfc5444.c         # RFC 5444 parser/serializer
    └── route_table.c     # route table with timers
```

### Zephyr route API

The Zephyr networking stack provides a route management API in
`subsys/net/ip/route.h`:

- `net_route_add()` - add a route (fires `NET_EVENT_IPV6_ROUTE_ADD`)
- `net_route_del()` - remove a route (fires `NET_EVENT_IPV6_ROUTE_DEL`)
- `net_route_lookup()` - longest-prefix-match lookup
- `net_route_update_lifetime()` - refresh route expiration timer
- `net_route_foreach()` - iterate all routes

**Important**: the next hop must exist in the IPv6 neighbor cache before adding
a route. Use `net_ipv6_nbr_add()` first.

RPL routing support was removed from Zephyr. The routing table infrastructure
remains available for external modules to populate.

### Challenge: no "route not found" hook

The IPv6 stack (`ipv6_route_packet()` in `subsys/net/ip/ipv6.c`) silently drops
packets with no route. There is no pluggable callback mechanism.

Options to address this:

1. **Patch the Zephyr fork** to add a hook in `ipv6_route_packet()` that calls
   into the AODVv2 module when no route is found.
2. **Intercept at socket level**: check `net_route_lookup()` before sending and
   trigger RREQ if the route is missing.

### Multicast group

AODVv2 uses the LL-MANET-Routers multicast address `ff02::6d` (RFC 5498) for
RREQ flooding. In Zephyr:

- Low-level: `net_if_ipv6_maddr_add(iface, &addr)` +
  `net_if_ipv6_maddr_join()`
- Socket-level: `setsockopt(fd, IPPROTO_IPV6, IPV6_ADD_MEMBERSHIP, ...)`

### Protocol timers

Use `k_work_delayable` (not `k_timer`) for all protocol timers. Work items
execute in thread context, allowing safe use of networking APIs.

- Route expiration: a single `k_work_delayable` managing a sorted list of
  timeouts
- RREQ retransmission: a dedicated `k_work_delayable` with exponential backoff

### Implementation dependencies

1. RFC 5444 parser/serializer (does not exist in Zephyr)
2. AODVv2 protocol state machine
3. Route table with expiration timers (`k_work_delayable`)
4. Integration with Zephyr `net_route` API
5. Multicast socket on `ff02::6d`

## References

### IETF drafts

- [draft-ietf-manet-aodvv2-16](https://datatracker.ietf.org/doc/html/draft-ietf-manet-aodvv2-16)
  (last Working Group draft)
- [draft-perkins-manet-aodvv2-06](https://datatracker.ietf.org/doc/draft-perkins-manet-aodvv2/)
  (last individual draft)
- [RFC 3561 - AODV](https://datatracker.ietf.org/doc/html/rfc3561) (predecessor)
- [RFC 5444 - Generalized MANET Packet/Message Format](https://datatracker.ietf.org/doc/html/rfc5444)
- [RFC 5498 - IANA Allocations for MANET](https://datatracker.ietf.org/doc/html/rfc5498)
  (defines `ff02::6d`)

### Implementations and related projects

- [Lotterleben/RIOT-AODVv2](https://github.com/Lotterleben/RIOT-AODVv2) (RIOT
  OS implementation by Lotte Steenbrink)
- [btcven/turpial-firmware](https://github.com/btcven/turpial-firmware) (Locha
  Mesh on RIOT OS)
- [btcven/locha](https://github.com/btcven/locha) (Locha project overview)
- [erimatnor/aodv-uu](https://github.com/erimatnor/aodv-uu) (AODV v1 Linux
  user-space)
- [RIOT OS - Locha use case](https://www.riot-os.org/use_cases/locha.html)

### Zephyr RTOS references

- [Zephyr IEEE 802.15.4 documentation](https://docs.zephyrproject.org/latest/connectivity/networking/api/ieee802154.html)
- [Zephyr networking API](https://docs.zephyrproject.org/latest/connectivity/networking/api/index.html)
- [Zephyr PR #9210 - BLE mesh AODV (rejected)](https://github.com/zephyrproject-rtos/zephyr/pull/9210)
- [OpenThread on Zephyr](https://openthread.io/platforms/rtos/zephyr)
- Zephyr route API: `subsys/net/ip/route.h`, `subsys/net/ip/route.c`
- Zephyr IPv6 forwarding: `subsys/net/ip/ipv6.c` (`ipv6_route_packet()`)
- Zephyr net events: `include/zephyr/net/net_event.h`
- Zephyr module system: `scripts/zephyr_module.py`,
  `cmake/modules/zephyr_module.cmake`

### Related protocols

- [LOADng: Towards AODVv2 (PDF)](https://polytechnique.hal.science/hal-02263401/file/2012-IEEE-VTC-LOADng-Towards-AODVv2.pdf)
  (lightweight AODV derivative, ITU-T G.9903, simpler message format without
  RFC 5444)
- [RFC 6550 - RPL](https://datatracker.ietf.org/doc/html/rfc6550) (tree-based
  routing for LLNs, not suitable for P2P mesh)

### Academic

- AODVv2 ARM user-space implementation (IEEE 2021):
  [DOI 10.1109/ISIE45552.2021.9615672](https://ieeexplore.ieee.org/document/9615672/)
- AODVv2 ns-3 model (2025 ns-3 workshop):
  [DOI 10.1145/3747204.3747219](https://dl.acm.org/doi/10.1145/3747204.3747219)
