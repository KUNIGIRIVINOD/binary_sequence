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

    # Input bit sequence: 1 0 1 1 should detect sequence
    seq = [1, 0, 1, 1]
    for bit in seq:
        dut.ui_in.value = bit
        await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value == 1, "Sequence 1011 not detected!"

    # Try another sequence without 1011
    seq = [1, 1, 0, 0]
    for bit in seq:
        dut.ui_in.value = bit
        await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value == 0, "False detection occurred!"
