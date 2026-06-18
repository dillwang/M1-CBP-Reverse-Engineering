ENTRY(_start)

PHDRS
{
  textlow  PT_LOAD FLAGS(5);
  phrref   PT_LOAD FLAGS(5);
  phrtest  PT_LOAD FLAGS(5);
  br1seg   PT_LOAD FLAGS(5);
  br2seg   PT_LOAD FLAGS(5);
  data     PT_LOAD FLAGS(6);
}

SECTIONS
{
  . = 0x0000000000400000;
  .text : ALIGN(0x1000)
  {
    *(.text.startup*)
    *(.text .text.*)
  } :textlow

  . = 0x0000000101000000;
  .phr_ref : ALIGN(0x1000)
  {
    *(.phr_ref)
  } :phrref

  . = 0x0000000201000000;
  .phr_test : ALIGN(0x1000)
  {
    *(.phr_test)
  } :phrtest

  . = 0x0000000100000000;
  .br1 : ALIGN(0x1000)
  {
    *(.br1)
  } :br1seg

  . = 0x0000000200000000;
  .br2 : ALIGN(0x1000)
  {
    *(.br2)
  } :br2seg

  . = ALIGN(0x1000);
  .data : { *(.data .data.*) } :data
  .bss  : { *(.bss .bss.* COMMON) } :data
}