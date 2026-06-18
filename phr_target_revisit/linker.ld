ENTRY(_start)

SECTIONS
{
    /*
     * Keep everything within branch range:
     *
     *   .text.main      at 0x400000
     *   .text.init      at 0x410000
     *   .text.train_tgt at 0x500000
     *
     */

    .text.main 0x400000 : {
        *(.text.main)
    }

    .text.init 0x410000 : {
        *(.text.init)
    }

    .text.train_tgt 0x500000 : {
        *(.text.train_tgt)
    }
}