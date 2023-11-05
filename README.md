# KCBench Compilation Test Script

This script automates the process of running compilation tests of [KCBench](git@gitlab.com:knurd42/kcbench.git) on various architectures, including X86-64, arm64, riscv, and powerpc. It also provides instruction on how to setup containerized and virtualized envieronments. The script generates detailed compilation results and stores them in log files with timestamps for reference.

## Prerequisites

Before running the KCBench compilation tests, ensure that you have the following dependencies installed on your system:

gcc-powerpc64le-linux-gnu

- `bc`
- `bison`
- `curl`
- `flex`
- `make`
- `time`
- `perl`
- `gcc`
- `pkg-config`
- `git`
- `tar`
- `elfutils-libelf-devel`
- `openssl-devel`
- `gcc-powerpc64-linux-gnu`
- `gcc-arm-linux-gnu`
- `gcc-aarch64-linux-gnu`
- `gcc-riscv64-linux-gnu`
- `qemu`
- `lxc`
- `lxc-templates`
- `lxc-extra`
- `debootstrap`
- `libvirt`
- `perl`
- `gpg`
- `wget`
- `gcc-x86_64-linux-gnu`
- `gcc-c++-powerpc64-linux-gnu`
- `gcc-c++-powerpc64le-linux-gnu`
- `gcc-powerpc64le-linux-gnu`
- `openssl`
- `virt-install`

You can install these packages using your system's package manager or by building them from source.
```bash
dnf install bc bison curl flex make time perl gcc pkg-config git tar elfutils-libelf-devel openssl-devel gcc-powerpc64-linux-gnu gcc-arm-linux-gnu gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu qemu lxc lxc-templates lxc-extra debootstrap libvirt perl gpg wget gcc-c++-powerpc64-linux-gnu gcc-c++-powerpc64le-linux-gnu gcc-powerpc64le-linux-gnu openssl virt-install gcc-x86_64-linux-gnu
```

## Setting Up an LXC Container with Fedora 38

To run the KCBench compilation tests in an LXC container with Fedora 38, follow these steps:

1. Install LXC on your system if it's not already installed. You can usually install it via your system's package manager.

2. Start lxc, make sure lxc is enabled and running

   ```bash
   systemctl enable --now lxc
   ```

2. Create an LXC container using the Fedora 38 image:

   ```bash
   lxc-create -n fedora-container -t download -- -d fedora -r 38 -a amd64
   ```

3. Start the LXC container:

   ```bash
   lxc-start fedora-container
   ```

4. Enter the container's shell:

   ```bash
   lxc-attach fedora-container
   ```

5. Inside the container, update the system packages and install any required dependencies not already included in the Fedora image:

   ```bash
   dnf update -y
   dnf install -y bc bison curl flex make time perl gcc pkg-config git tar elfutils-libelf-devel openssl-devel gcc-powerpc64-linux-gnu gcc-arm-linux-gnu gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu qemu lxc lxc-templates lxc-extra debootstrap libvirt perl gpg wget gcc-c++-powerpc64-linux-gnu gcc-c++-powerpc64le-linux-gnu gcc-powerpc64le-linux-gnu openssl virt-install cpufrequtils gcc-x86_64-linux-gnu
   ```

6. Clone the KCBench repository within the container:

   ```bash
   git clone git@github.com:zampierilucas/tcc-tests.git --recurse-submodules
   ```

7. Change to the KCBench directory:

   ```bash
   cd tcc-tests
   ```

8. Run the KCBench compilation tests using the script provided with this repo.

9. When you're done testing, exit the container's shell and stop the container:

   ```bash
   lxc stop my-fedora-container
   ```

## Setting Up a QEMU Virtual Machine

To run the KCBench compilation tests in a QEMU virtual machine, follow these steps:

1. Install QEMU on your system if it's not already installed. It is also provided as part of the dependencies section above.

2. Download a QEMU-compatible disk image for the desired architecture. For our use case, fedora 38 x86-64:

   ```bash
   wget https://download.fedoraproject.org/pub/fedora/linux/releases/38/Server/x86_64/images/Fedora-Server-KVM-38-1.6.x86_64.qcow2
   ```

3. Virtio setup, we need to setup and start the kvm interface before creating our vm.

   ```
   usermod -aG libvirt $usermod
   # Logout and login to reload group policies
   systemctl enable --now libvirtd
   ```

3. Create a QEMU virtual machine using the downloaded disk image:

   ```bash
   qemu-system-x86_64 \
      -smp cpus=256,sockets=2 \
      -M q35 \
      -cpu host \
      -enable-kvm \
      -m 100G \
      -nographic \
      -drive file=Fedora-Server-KVM-38-1.6.x86_64.qcow2
   ```

   Customize the CPU type, memory, kmv emulator and smp settings as needed for your tests.

4. Inside the virtual machine, you can now clone the KCBench repository and run the compilation tests using the script provided.

5. When you're done testing, you can exit the virtual machine by shutting it down from within the VM or by stopping the QEMU process.

