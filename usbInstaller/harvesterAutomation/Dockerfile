# Use an official Ubuntu as a base image
FROM ubuntu:22.04

# Set environment variables to prevent prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for Hauler, xorriso, and genisoimage
RUN apt-get update && \
    apt-get install -y \
    curl \
    xorriso \
    genisoimage \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Hauler from the official source
RUN curl -sfL https://get.hauler.dev | bash

# Set up the working directory
WORKDIR /working

# Default command (optional: can be replaced with a different command as needed)
CMD ["bash"]
