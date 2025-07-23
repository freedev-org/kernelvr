import gdb

class WaitBreakpoint(gdb.Breakpoint):
    path: str

    def __init__(self, path: str):
        super().__init__("do_execveat_common", gdb.BP_BREAKPOINT)
        self.path = path

    def stop(self):
        filename = gdb.parse_and_eval("(struct filename *)$rsi")
        path = filename["name"].string()

        if path == self.path:
            print(f"Stopped for process: {path}")
            print("Getting PID...")

            pid = int(gdb.parse_and_eval("$lx_current().pid"))
            print(f"PID: {pid}")
            return True

        return False

class WaitCommand(gdb.Command):
    """
Wait the given program to run and then stop.

Usage:
    kvr_wait <path>

    path    The path for the binary to wait.
    """

    breakpoint: WaitBreakpoint | None = None

    def __init__(self):
        super().__init__("kvr_wait", gdb.COMMAND_USER)

    def invoke(self, argument: str, from_tty: bool):
        if self.breakpoint is not None:
            self.breakpoint.delete()

        self.breakpoint = WaitBreakpoint(argument)


WaitCommand()
