define kvr_start
    hbreak start_kernel
    continue
end

define kvr_rstart
    if $argc == 0
        set $addr = ":1234"
    else
        set $addr = $arg0
    end

    target remote $addr
    kvr_start
end

document kvr_start
Start the kernel and stop on start_kernel() function.
end

document kvr_rstart
Connect to remote target and run kvr_start command.

Usage:
    kvr_rstart [addr]

    addr      The remote address to connect. Default: "localhost:1234"
end
