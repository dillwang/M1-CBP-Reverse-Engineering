ENTRY(_start)

PHDRS
{
  textlow PT_LOAD FLAGS(5);  /* R + X */-
  phrseg  PT_LOAD FLAGS(5);  /* R + X */
  br1seg  PT_LOAD FLAGS(5);  /* R + X */
  br2seg  PT_LOAD FLAGS(5);  /* R + X */
  data    PT_LOAD FLAGS(6);  /* R + W */
}

SECTIONS
{
  /* Low text: only _start and normal low code */
  . = 0x0000000000400000;
  .text : ALIGN(0x1000)
  {
    *(.text.startup*)
    *(.text .text.*)
  } :textlow

  /* Put func_set_phr near branch1, but still reachable from branch2 by adrp */
  . = 0x0000000101000000;
  .phr : ALIGN(0x1000)
  {
    *(.phr)
  } :phrseg

  /* branch1 pinned here */
  . = 0x0000000100000000;
  .br1 : ALIGN(0x1000)
  {
    *(.br1)
  } :br1seg

  /* branch2 pinned here */
  . = 0x0000000200000000;
  .br2 : ALIGN(0x1000)
  {
    *(.br2)
  } :br2seg

  /* Data/BSS */
  . = ALIGN(0x1000);
  .data : { *(.data .data.*) } :data
  .bss  : { *(.bss .bss.* COMMON) } :data
}