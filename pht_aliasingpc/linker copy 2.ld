ENTRY(_start)

PHDRS
{
  textlow PT_LOAD FLAGS(5);
  texthi  PT_LOAD FLAGS(5);
  data    PT_LOAD FLAGS(6);
}

SECTIONS
{
  . = 0x0000000000400000;
  .text : ALIGN(0x1000)
  {
    *(.text.startup*)
    *(.text0*)
    *(.text .text.*)
    *(.rodata .rodata.*)
  } :textlow

  . = 0x0000000100000000
  .br1 : ALIGN(0x1000) { *(.br1) } :texthi

  . = 0x0000000200000000;
  .br2 : ALIGN(0x1000) { *(.br2) } :texthi

  . = ALIGN(0x1000);
  .data : { *(.data .data.*) } :data
  .bss  : { *(.bss .bss.* COMMON) } :data
}