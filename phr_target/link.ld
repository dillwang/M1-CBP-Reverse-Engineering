SECTIONS
{
  /* Place tgt0 on a page boundary to make low-bit n meaningful and predictable */
  . = ALIGN(0x1000);
  .tgt0 : { KEEP(*(.tgt0)) }

  /* Place tgt1 exactly n bytes after tgt0 */
  . = ADDR(.tgt0) + 0x80000000;
  .tgt1 : { KEEP(*(.tgt1)) }
}
INSERT AFTER .text;
