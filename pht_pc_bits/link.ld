SECTIONS
{
  . = ALIGN(0x1000);

  /* Place TB1 at an address with low A bits zero */
  . = ALIGN(0x100000);
  .tb1 : { KEEP(*(.tb1)) }

  /* Place TB2 exactly 2^A bytes after TB1 */
  . = ADDR(.tb1) + 0x100000;
  .tb2 : { KEEP(*(.tb2)) }
}
INSERT AFTER .eh_frame;
