ENTRY(_start)

PHDRS
{
  text0 PT_LOAD FLAGS(5);
  text1 PT_LOAD FLAGS(5);
  data  PT_LOAD FLAGS(6);
}

SECTIONS
{
  . = 0x0000000100000000;
  .br1 : ALIGN(0x1000) { *(.br1) } :text0

  . = ALIGN(0x1000);
  .text0 : ALIGN(0x1000)
  {
    *(.text.startup*)
    *(.text0*)
    *(.text .text.*)
  } :text0

  . = 0x0000000200000000;
  .br2 : ALIGN(0x1000) { *(.br2) } :text1

  . = ALIGN(0x1000);
  .text1 : ALIGN(0x1000) { *(.text1*) } :text1

  . = 0x0000000101000000;
  . = ALIGN(0x1000);
  .data : { *(.data .data.*) } :data
  .bss  : { *(.bss .bss.* COMMON) } :data
}