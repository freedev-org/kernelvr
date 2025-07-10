# kernelvr

Here you can find some tools to build, debug and security research the Linux kernel.

## Linux dependencies

You need to install the following packages to be able to build the kernel:

```bash
sudo apt install fakeroot build-essential flex bison libssl-dev libelf-dev ncurses-dev dwarves xz-utils bc
```

## Makefile commands

| Command      | Example                          | Description                                                                 |
|--------------|----------------------------------|-----------------------------------------------------------------------------|
| `download`   | `make download VERSION=6.15.5`   | Download the linux source code and creates a `./linux` symbolic link to it  |
| `build`      | `make build VERSION=6.15.5`      | Download (if not downloaded yet) and build the Linux source code            |
| `switch`     | `make switch VERSION=6.15.5`     | Switch the symbolic link `./linux` to the source code of the given version  |
| `vm`         | `make vm VERSION=6.15.5`         | Run a QEMU virtual machine with the Linux                                   |
| `debug`      | `make debug VERSION=6.15.5`      | Run the GDB to debug the Linux                                              |

## Tools

**Note**: All the tools have help messages with `--help` option.

| Tool                | Description                                                                     |
|---------------------|---------------------------------------------------------------------------------|
| `gitmon.sh`         | Monitory the changes on a git repository.                                       |
