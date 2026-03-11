<!--
Copyright (c) 2026 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
Copyright (c) 2026 Luis Ruiz <luisan00@hotmail.com>

SPDX-License-Identifier: Apache-2.0
-->

# Firmware

## Prerequisites

- [Zephyr SDK](https://docs.zephyrproject.org/latest/develop/toolchains/zephyr_sdk.html)
- [west](https://docs.zephyrproject.org/latest/develop/west/index.html)

## Setup

Activate the Python virtual environment where west is installed:

```shell
source ~/zephyrproject/.venv/bin/activate
```

Initialize the workspace and fetch dependencies:

```shell
west init -l .
west update
```

## Building

```shell
west build -b turpial/cc1312r mesh-router
```

For a clean build:

```shell
west build -b turpial/cc1312r mesh-router -p
```

## Flashing

```shell
west flash
```

The board uses an XDS110 debugger with OpenOCD.

## Serial console

Connect to the shell via serial at 115200 baud:

```shell
minicom -D /dev/tty.usbmodemXXXX -b 115200
```

To exit minicom: `Esc`, then `X`, then confirm.

## Roadmap

See [docs/roadmap.md](docs/roadmap.md) for the development roadmap.

## License

This project is licensed under the [Apache License 2.0](LICENSE).
