FROM ubuntu:22.04

# 1. Install ttyd and QEMU
RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    ttyd \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 2. Download the OS image
# Using the smaller "Generic" image to avoid build timeouts
RUN wget -O /os.img https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# 3. Create the startup script
# We expose port 7681 for the browser terminal
RUN echo '#!/bin/bash \n\
ttyd -p 7681 qemu-system-x86_64 \
    -m 4G \
    -smp 4 \
    -cpu max \
    -drive file=/os.img,format=qcow2 \
    -nographic \
    -serial mon:stdio \
    -net user,hostfwd=tcp::2222-:22 \
    -net nic' > /entrypoint.sh && chmod +x /entrypoint.sh

# 4. Railway uses the PORT environment variable, but we will force 7681
EXPOSE 7681

CMD ["/entrypoint.sh"]
