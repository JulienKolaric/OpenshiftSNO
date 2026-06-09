#!/bin/bash
# Wrapper vfkit : ajoute --nested pour virtualisation imbriquée (Mac M3+ / macOS 15+)
exec /usr/local/crc/vfkit "$@" --nested
