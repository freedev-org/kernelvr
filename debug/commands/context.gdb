define kvr_context
    printf "PC = 0x%016lx | SP = 0x%016lx\n", $pc, $sp
    info registers eflags
    echo -------------------------------\n
    x/10gx $sp
    echo -------------------------------\n
    x/15i $pc
    echo -------------------------------\n
    frame
end

document kvr_context
Show some informations about where you are.
end
