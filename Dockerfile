FROM ubuntu:22.04

# Install QEMU and dependencies
RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download the Ubuntu Cloud Image automatically during build
RUN wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# Set up the startup script
RUN echo '#!/bin/bash \n\
if [ -e /dev/kvm ]; then \n\
  echo "--- KVM DETECTED! POWER MODE ENABLED ---" \n\
  qemu-system-x86_64 -m 8G -smp 4 -cpu host -enable-kvm -drive file=jammy-server-cloudimg-amd64.img,format=qcow2 -net user,hostfwd=tcp::2222-:22 -net nic -vnc :0 -vga std \n\
else \n\
  echo "--- NO KVM DETECTED! EMULATION MODE ---" \n\
  qemu-system-x86_64 -m 4G -smp 2 -cpu max -drive file=jammy-server-cloudimg-amd64.img,format=qcow2 -net user,hostfwd=tcp::2222-:22 -net nic -vnc :0 -vga std \n\
fi' > start.sh && chmod +x start.sh

# Open VNC Port
EXPOSE 5900

CMD ["./start.sh"]
