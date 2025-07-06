SRC_URL=https://cdn.kernel.org/pub/linux/kernel/v{major}.x/linux-{version}.tar.xz

QEMU=qemu-system-x86_64
QEMU_FLAGS= -enable-kvm \
	-m 1024 \
	-cpu host \
	-smp 2 \
	-nic user,model=virtio \
	-display curses \
	-drive file=$(DISK),format=qcow2

# kvr.gdb base path used to source files
GDB_BPATH ?= $(PWD)
GDB_COMMANDS := $(wildcard debug/commands/*.gdb)

define url
	$(subst {major},$(word 1,$(subst ., ,$1)),$(subst {version},$1,$2))
endef

all: vm

.PHONY: vm
vm:
	$(QEMU) $(QEMU_FLAGS)

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

.versions/$(VERSION): .versions linux-$(VERSION).tar.xz
	tar -xf linux-$(VERSION).tar.xz -C .versions
	mv .versions/linux-$(VERSION) $@
	touch $@

.versions:
	mkdir -p $@

linux-$(VERSION).tar.xz:
	wget $(call url,$(VERSION),$(SRC_URL)) -O linux-$(VERSION).tar.xz

kvr.gdb: $(GDB_COMMANDS)
	@rm -f $@

	@for cmd in $(GDB_COMMANDS); do \
		echo "source \"$(GDB_BPATH)/$$cmd\"" >> $@; \
	done


.PHONY: check_version
check_version:
ifndef VERSION
	@echo Error: VERSION is a required argument. Try: make build VERSION=1.2.3 >&2
	@exit 1
endif
