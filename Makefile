SRC_URL=https://cdn.kernel.org/pub/linux/kernel/v{major}.x/linux-{version}.tar.xz
ROOTFS_URL=https://storage.googleapis.com/kernelctf-build/files/rootfs_v3.img.gz
RAMDISK_URL=https://storage.googleapis.com/kernelctf-build/files/ramdisk_v1.img

HOST_PATH=./host
KSYSCTL_FLAGS=sysctl.net.core.bpf_jit_harden=2 sysctl.kernel.io_uring_disabled=2
KCONFIG_FLAGS=console=ttyS0 root=/dev/vda1 rootfstype=ext4 rootflags=discard
KINIT=/bin/bash
QEMU=qemu-system-x86_64
QEMU_FLAGS= -enable-kvm \
	-m 1024 \
	-cpu host \
	-smp 2 \
	-nic user,model=virtio-net-pci \
	-monitor none \
	-nographic \
	-no-reboot \
	-initrd ramdisk.img \
	-drive file=rootfs.img,if=virtio,cache=none,aio=native,format=raw,discard=on,readonly=on \
	-virtfs local,path=$(HOST_PATH),mount_tag=host,security_model=passthrough,readonly=on \
	-kernel "releases/$(VERSION)/bzImage" \
	-append "$(KCONFIG_FLAGS) $(KSYSCTL_FLAGS) nokaslr ro init=$(KINIT) hostname=linux$(VERSION)" \
	-s -S

# kvr.gdb base path used to source files
GDB_BPATH ?= $(PWD)
GDB_COMMANDS := $(wildcard debug/commands/*.gdb)

SRC=./linux

define url
	$(subst {major},$(word 1,$(subst ., ,$1)),$(subst {version},$1,$2))
endef

all: vm

.PHONY: vm
vm: check_version ramdisk.img rootfs.img
	@if [ "$(HOST_PATH)" = "./host" ]; then mkdir -p $(HOST_PATH); fi
	$(QEMU) $(QEMU_FLAGS)

.PHONY: debug
debug: check_version kvr.gdb
	gdb -x kvr.gdb "releases/$(VERSION)/vmlinux"

.PHONY: build
build: check_version download
	@./scripts/build.sh ./linux $(VERSION)

.PHONY: download
download: check_version .versions/$(VERSION)
	@$(MAKE) --no-print-directory switch

.PHONY: switch
switch: check_version
	@[ ! -d .versions/$(VERSION) ] && echo "Error: Version $(VERSION) not found. Download it first!" >&2 && exit 1 || true
	rm ./linux
	ln -fs $(PWD)/.versions/$(VERSION) ./linux

# Install: sudo apt install global cscope universal-ctags
codesearch-index:
	$(MAKE) -C $(SRC) tags cscope

codesearch:
	cd $(SRC) && cscope -d

.versions/$(VERSION): .versions linux-$(VERSION).tar.xz
	tar -xf linux-$(VERSION).tar.xz -C .versions
	mv .versions/linux-$(VERSION) $@
	touch $@

.versions:
	mkdir -p $@

linux-$(VERSION).tar.xz:
	wget $(call url,$(VERSION),$(SRC_URL)) -O linux-$(VERSION).tar.xz

rootfs.img:
	wget $(ROOTFS_URL) -O "$@.gz"
	gzip -d "$@.gz"

ramdisk.img:
	wget $(RAMDISK_URL) -O "$@"

kvr.gdb: $(GDB_COMMANDS) debug/main.gdb
	@rm -f $@

	@for cmd in $(GDB_COMMANDS); do \
		echo "source $(GDB_BPATH)/$$cmd" >> $@; \
	done

	@(echo; cat debug/main.gdb) >> $@


.PHONY: check_version
check_version:
ifndef VERSION
	@echo Error: VERSION is a required argument. Try: make $(MAKECMDGOALS) VERSION=1.2.3 >&2
	@exit 1
endif
