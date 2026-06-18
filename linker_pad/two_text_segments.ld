ENTRY(_start)

PHDRS
{
  text0 PT_LOAD FLAGS(5); /* R + X */
  text1 PT_LOAD FLAGS(5); /* R + X */
  data  PT_LOAD FLAGS(6); /* R + W */
}

SECTIONS
{
  /* Code region A: low 32 bits = 0 */
  . = 0x0000000100000000;
  . = ALIGN(0x1000);
  .text0 : ALIGN(0x1000)
  {
    *(.text0*)
    *(.text.startup*)
    *(.text .text.*)
  } :text0

  /* Code region B: differs by bit 32 (4GB) */
  . = 0x0000000200000000;
  . = ALIGN(0x1000);
  .text1 : ALIGN(0x1000)
  {
    *(.text1*)
  } :text1

  /* Simple data region near text0 so relocs stay tame */
  . = 0x0000000101000000;
  . = ALIGN(0x1000);
  .data : { *(.data .data.*) } :data
  .bss  : { *(.bss .bss.* COMMON) } :data
}
