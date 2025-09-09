# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    dut._log.info("Testing Binary Sequence Detector (1011)")

    # Feed the sequence 1,0,1,1 and check detection
    seq = [1, 0, 1, 1]
    for idx, bit in enumerate(seq, start=1):
        dut.ui_in.value = bit
        await ClockCycles(dut.clk, 1)
        dut._log.info(f"After {idx} bits, uo_out={int(dut.uo_out.value)}")

    # Now detection should have happened
    assert dut.uo_out.value == 1, "Sequence 1011 not detected!"

    # Test another sequence that does not contain 1011
    seq = [1, 1, 0, 0]
    for idx, bit in enumerate(seq, start=1):
        dut.ui_in.value = bit
        await ClockCycles(dut.clk, 1)
        dut._log.info(f"After {idx} bits (non-matching), uo_out={int(dut.uo_out.value)}")

    # No detection expected here
    assert dut.uo_out.value == 0, "False detection occurred!"
