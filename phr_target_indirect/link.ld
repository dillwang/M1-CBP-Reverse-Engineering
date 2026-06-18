SECTIONS
{
  . = ALIGN(0x1000);
  .tgt0 : { KEEP(*(.tgt0)) }

  . = ADDR(.tgt0) + 0x80000000;
  .tgt1 : { KEEP(*(.tgt1)) }
}
INSERT AFTER .eh_frame;
