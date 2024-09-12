# TCC Test scripts and data

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

## Setting Up an LXC Container with Fedora 40

To run the KCBench compilation tests in an LXC container with Fedora 40, follow these steps:

1. Install LXC on your system.

   ```bash
   sudo dnf install lxc lxc-templates
   ```

2. Start lxc, make sure lxc is enabled and running

   ```bash
   systemctl enable --now lxc
   ```

3. Create an LXC container using a Fedora 40 image:

   ```bash
   lxc-create -n fedora-container -t download -- -d fedora -r 40 -a amd64
   ```

4. Mount the host /root directory to the container's home directory. This can be done by editing the container's configuration file, typically located at /var/lib/lxc/fedora-container/config. Add the following line to the configuration file:

   ```bash
   lxc.mount.entry = /root mnt/host-root none bind,create=dir 0 0
   ```

5. Start the LXC container:

   ```bash
   lxc-start fedora-container
   ```

6. Enter the container's shell:

   ```bash
   lxc-attach fedora-container
   ```

7. inside the container install this project dependencies as shown [here](#Dependencies).

## Setting Up a Docker Container with Fedora 40

To run the KCBench compilation tests in a Docker container with Fedora 40, follow these steps:

1. Install Docker on your system.

   ```bash
   sudo dnf -y install dnf-plugins-core
   sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
   sudo dnf install docker-ce docker-ce-cli containerd.io
   ```

2. Start the Docker service:

   ```bash
   sudo systemctl start docker
   ```

3. Pull the Fedora 40 Docker image:

   ```bash
   sudo docker pull fedora:40
   ```

4. Create a Docker container using the Fedora 40 image:

   ```bash
   sudo docker run -it -v /root:/mnt/host-root --name fedora-container fedora:40
   ```

5. Install the project dependencies inside the container as shown [here](#Dependencies).

6. You can now proceed with cloning the KCBench repository and running the compilation tests.

## Setting Up a Podman Container with Fedora 40

To run the KCBench compilation tests in a Podman container with Fedora 40, follow these steps:

1. Install Podman on your system (if not already installed):

   ```bash
   sudo dnf install podman
   ```

2. Pull the Fedora 40 Podman image:

   ```bash
   podman pull fedora:40
   ```

3. Create a Podman container using the Fedora 40 image:

   ```bash
   podman run -it -v /root:/mnt/host-root --security-opt label=disable --name fedora-container fedora:40
   ```

4. Install the project dependencies inside the container as shown [here](#Dependencies).

5. You can now proceed with cloning the KCBench repository and running the compilation tests.

Note: Podman is designed to be a drop-in replacement for Docker, so most Docker commands can be used with Podman by simply replacing `docker` with `podman` in the command.

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
