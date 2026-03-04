# Copyright (c) 2026 Jean-Pierre De Jesus DIAZ <me@jeandudey.tech>
#
# SPDX-License-Identifier: Apache-2.0

if(CONFIG_SOC_CC1312R)
  board_runner_args(openocd "--config=${BOARD_DIR}/support/openocd_cc1312r.cfg")

  include(${ZEPHYR_BASE}/boards/common/openocd.board.cmake)
endif()

if(CONFIG_SOC_ESP32)
  if(NOT "${OPENOCD}" MATCHES "^${ESPRESSIF_TOOLCHAIN_PATH}/.*")
    set(OPENOCD OPENOCD-NOTFOUND)
  endif()
  find_program(OPENOCD openocd PATHS ${ESPRESSIF_TOOLCHAIN_PATH}/openocd-esp32/bin NO_DEFAULT_PATH)

  include(${ZEPHYR_BASE}/boards/common/esp32.board.cmake)
  include(${ZEPHYR_BASE}/boards/common/openocd.board.cmake)
endif()
