set $kvr_hooks = 1

define kvr_hooks
    set $kvr_hooks = $arg0
end

document kvr_hooks
Usage: kvr_hooks 0|1

Enable or disable the execution of kvr_context after each step.
end


define hook-next
    if $kvr_hooks
        kvr_context
    end
end

define hook-nexti
    if $kvr_hooks
        kvr_context
    end
end

define hook-step
    if $kvr_hooks
        kvr_context
    end
end

define hook-stepi
    if $kvr_hooks
        kvr_context
    end
end
