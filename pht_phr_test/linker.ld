ENTRY(_start)

PHDRS
{
  textlow  PT_LOAD FLAGS(5);
  phrref   PT_LOAD FLAGS(5);
  phrtest  PT_LOAD FLAGS(5);

  br1seg   PT_LOAD FLAGS(5);
  br2seg   PT_LOAD FLAGS(5);
  br3seg   PT_LOAD FLAGS(5);
  br4seg   PT_LOAD FLAGS(5);
  br5seg   PT_LOAD FLAGS(5);
  br6seg   PT_LOAD FLAGS(5);
  br7seg   PT_LOAD FLAGS(5);
  br8seg   PT_LOAD FLAGS(5);

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

  . = 0x0000000901000000;
  .phr_ref : ALIGN(0x1000)
  {
    *(.phr_ref)
  } :phrref

  . = 0x0000000a01000000;
  .phr_test : ALIGN(0x1000)
  {
    *(.phr_test)
  } :phrtest

  . = 0x0000000100000000;
  .branch1 : ALIGN(0x1000)
  {
    *(.branch1)
  } :br1seg

  . = 0x0000000200000000;
  .branch2 : ALIGN(0x1000)
  {
    *(.branch2)
  } :br2seg

  . = 0x0000000300000000;
  .branch3 : ALIGN(0x1000)
  {
    *(.branch3)
  } :br3seg

  . = 0x0000000400000000;
  .branch4 : ALIGN(0x1000)
  {
    *(.branch4)
  } :br4seg

  . = 0x0000000500000000;
  .branch5 : ALIGN(0x1000)
  {
    *(.branch5)
  } :br5seg

  . = 0x0000000600000000;
  .branch6 : ALIGN(0x1000)
  {
    *(.branch6)
  } :br6seg

  . = 0x0000000700000000;
  .branch7 : ALIGN(0x1000)
  {
    *(.branch7)
  } :br7seg

  . = 0x0000000800000000;
  .branch8 : ALIGN(0x1000)
  {
    *(.branch8)
  } :br8seg

  . = ALIGN(0x1000);
  .data : { *(.data .data.*) } :data
  .bss  : { *(.bss .bss.* COMMON) } :data
}