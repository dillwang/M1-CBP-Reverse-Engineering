ENTRY(_start)

SECTIONS
{
    /*
     * Keep everything within branch range:
     *   .text.main      at 0x400000
     */

    .text.main 0x400000 : {
        *(.text.main)
    }

    .text.init 0x380000 : {
        *(.text.init)
    }

    .text.uncond_jumps 0x600000 : {
        *(.text.uncond_jumps)
    }

}