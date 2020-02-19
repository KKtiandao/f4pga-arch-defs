#!/usr/bin/env python3

# This file is Copyright (c) 2015-2019 Florent Kermarrec <florent@enjoy-digital.fr>
# License: BSD

import argparse

from migen import Module, ClockDomain, Signal, Instance
from litex.boards.platforms import arty
from litex.soc.integration.soc_core import SoCCore, soc_core_args, soc_core_argdict
from litex.soc.integration.builder import Builder, builder_args, builder_argdict
from litex.soc.cores.clock import S7PLL

# CRG ----------------------------------------------------------------------------------------------


class _CRG(Module):
    def __init__(self, platform, sys_clk_freq):
        self.clock_domains.cd_sys = ClockDomain()

        # # #

        self.cd_sys.clk.attr.add("keep")

        self.submodules.pll = pll = S7PLL(speedgrade=-1)
        self.comb += pll.reset.eq(~platform.request("cpu_reset"))
        pll_clkin = Signal()
        pll.register_clkin(pll_clkin, 100e6)
        pll.create_clkout(self.cd_sys, sys_clk_freq)

        self.specials += Instance(
            "BUFG", i_I=platform.request("clk100"), o_O=pll_clkin
        )


# BaseSoC ------------------------------------------------------------------------------------------


class BaseSoC(SoCCore):
    def __init__(
            self, sys_clk_freq=int(50e6), integrated_rom_size=0x8000, **kwargs
    ):
        platform = arty.Platform()
        SoCCore.__init__(
            self,
            platform,
            clk_freq=sys_clk_freq,
            integrated_rom_size=integrated_rom_size,
            integrated_sram_size=0x8000,
            ident="MiniLitex",
            cpu_variant="lite",
            **kwargs
        )

        self.submodules.crg = _CRG(platform, sys_clk_freq)


# Build --------------------------------------------------------------------------------------------


def main():
    parser = argparse.ArgumentParser(description="LiteX SoC on Arty")
    builder_args(parser)
    soc_core_args(parser)
    args = parser.parse_args()

    cls = BaseSoC
    soc = cls(**soc_core_argdict(args))
    builder = Builder(soc, **builder_argdict(args))
    builder.build()


if __name__ == "__main__":
    main()
