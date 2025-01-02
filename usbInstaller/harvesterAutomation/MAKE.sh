#!/bin/bash
# MAKE.sh - run all scripts in order and create Custom ISO

bash user_input.sh && \
bash create_configs.sh && \
bash pull_store_images.sh && \
bash create_iso.sh
