import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge

CLK_PERIOD_NS = 10


async def clocks(dut):

    async def mclk_period():
        dut.in_mclk.value = 0
        await Timer(5, units="ns")
        dut.in_mclk.value = 1
        await Timer(5, units="ns")

    async def sclk_period():
        dut.in_sclk.value = 0
        await mclk_period()
        await mclk_period()
        dut.in_sclk.value = 1
        await mclk_period()
        await mclk_period()

    async def fclk_period():
        dut.in_fclk.value = 0
        for i in range(32):
            await sclk_period()
        dut.in_fclk.value = 1
        for i in range(32):
            await sclk_period()

    while True:
        await fclk_period()


@cocotb.test()
async def test_i2s_rx(dut):

    dut.in_din.value = 0

    # clock
    cocotb.start_soon(clocks(dut))

    # reset
    dut.in_reset.value = 1
    await Timer(20 * CLK_PERIOD_NS, units="ns")
    dut.in_reset.value = 0

    await FallingEdge(dut.in_fclk)

    await FallingEdge(dut.in_sclk)

    await FallingEdge(dut.in_sclk)

    dut.in_din.value = 1

    await RisingEdge(dut.in_fclk)

    await FallingEdge(dut.in_sclk)

    for i in range(15):
        await FallingEdge(dut.in_sclk)

    dut.in_din.value = 0

    await FallingEdge(dut.in_fclk)
    await RisingEdge(dut.in_fclk)
