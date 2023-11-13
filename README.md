# KCBench Compilation Test Script

This script automates the process of running compilation tests of [KCBench](git@gitlab.com:knurd42/kcbench.git) on various architectures, including X86-64, arm64, riscv, and powerpc. It also provides instruction on how to setup containerized and virtualized envieronments. The script generates detailed compilation results and stores them in log files with timestamps for reference.

## Dependencies

Before running the KCBench compilation tests, ensure that you have the following dependencies installed on your system:

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

Command:
```bash
dnf update
dnf install bc bison curl flex make time perl gcc pkg-config git tar elfutils-libelf-devel openssl-devel gcc-powerpc64-linux-gnu gcc-arm-linux-gnu gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu qemu lxc lxc-templates lxc-extra debootstrap libvirt perl gpg wget gcc-c++-powerpc64-linux-gnu gcc-c++-powerpc64le-linux-gnu gcc-powerpc64le-linux-gnu openssl virt-install gcc-x86_64-linux-gnu
```

## Setting Up the HOST OS

For this we expect you to be running the same dist/os/version as in the container and virtual-machine, in our case Fedora 38.

1. For the host the only step is to install its dependencies, [here](#Dependencies).

## Setting Up an LXC Container with Fedora 38

To run the KCBench compilation tests in an LXC container with Fedora 38, follow these steps:

1. Install LXC on your system.

   ```bash
   sudo dnf install lxc lxc-templates
   ```

2. Start lxc, make sure lxc is enabled and running

   ```bash
   systemctl enable --now lxc
   ```

2. Create an LXC container using a Fedora 38 image:

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

4. inside the container install this project dependencies as shown [here](#Dependencies).

## Setting Up a KVM Virtual Machine

To run the KCBench compilation tests in a QEMU virtual machine, follow these steps:

1. Install the KVM tools in your system. It is also provided as part of the dependencies section above.

2. Download a qcow2 fedora 38 disk image. For our use case, fedora 38 x86-64:

   ```bash
   wget https://download.fedoraproject.org/pub/fedora/linux/releases/38/Server/x86_64/images/Fedora-Server-KVM-38-1.6.x86_64.qcow2
   ```

3. Aditinal kvm setup, we need to setup and start the kvm interface before creating our vm.

   ```
   usermod -aG libvirt $usermod
   # Logout and login to reload group policies
   systemctl enable --now libvirtd
   ```

3. Create a KVM virtual machine using the downloaded disk image:

   ```bash
   virt-install \
   --name fedora \
   --virt-type kvm \
   --boot hd \
   --disk path=Fedora-Server-KVM-38-1.6.x86_64.qcow2,device=disk \
   --graphics none \
   --cpu host \
   --os-variant=fedora38 \
   --import
   ```

4. inside the virtual-machine install this project dependencies as shown [here](#Dependencies).

## Running the tests

To reprodute this repository tests you will need to:

1. Clone the KCBench repository and its sub-repositories:

   ```bash
   git clone git@github.com:zampierilucas/tcc-tests.git --recurse-submodules
   ```

2. Enter its directory to the KCBench directory:

   ```bash
   cd tcc-tests
   ```

3. Run the KCBench compilation tests using the script provided with this repo `test-scripts` folder.
