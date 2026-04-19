FROM ubuntu:22.04

# Install QEMU, ttyd, and dependencies
RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    ttyd \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download Ubuntu Cloud Image
RUN wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# Create a startup script that runs ttyd AND QEMU
RUN echo '#!/bin/bash \n\
# Start ttyd on port 7681, which points to the QEMU serial console \n\
ttyd -p 7681 qemu-system-x86_64 \
    -m 16G \
    -smp 4 \
    -cpu max \
    -drive file=jammy-server-cloudimg-amd64.img,format=qcow2 \
    -nographic \
    -serial mon:stdio \
    -net user,hostfwd=tcp::2222-:22 \
    -net nic' > entrypoint.sh && chmod +x entrypoint.sh

# Expose the ttyd port
EXPOSE 7681

CMD ["./entrypoint.sh"]
