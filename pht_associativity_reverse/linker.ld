ENTRY(_start)

PHDRS
{
  textlow   PT_LOAD FLAGS(5);
  phrseg    PT_LOAD FLAGS(5);
  br1seg    PT_LOAD FLAGS(5);
  br2seg    PT_LOAD FLAGS(5);
  br3seg    PT_LOAD FLAGS(5);
  br4seg    PT_LOAD FLAGS(5);
  br5seg    PT_LOAD FLAGS(5);
  br6seg    PT_LOAD FLAGS(5);
  br7seg    PT_LOAD FLAGS(5);
  br8seg    PT_LOAD FLAGS(5);
  orderfseg PT_LOAD FLAGS(5);
  orderrseg PT_LOAD FLAGS(5);
  data      PT_LOAD FLAGS(6);
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
  .phr : ALIGN(0x1000)
  {
    *(.phr)
  } :phrseg

  . = 0x0000000100000000;
  .br1 : ALIGN(0x1000)
  {
    *(.branch1)
    *(.br1)
  } :br1seg

  . = 0x0000000200000000;
  .br2 : ALIGN(0x1000)
  {
    *(.branch2)
    *(.br2)
  } :br2seg

  . = 0x0000000300000000;
  .br3 : ALIGN(0x1000)
  {
    *(.branch3)
    *(.br3)
  } :br3seg

  . = 0x0000000400000000;
  .br4 : ALIGN(0x1000)
  {
    *(.branch4)
    *(.br4)
  } :br4seg

  . = 0x0000000500000000;
  .br5 : ALIGN(0x1000)
  {
    *(.branch5)
    *(.br5)
  } :br5seg

  . = 0x0000000600000000;
  .br6 : ALIGN(0x1000)
  {
    *(.branch6)
    *(.br6)
  } :br6seg

  . = 0x0000000700000000;
  .br7 : ALIGN(0x1000)
  {
    *(.branch7)
    *(.br7)
  } :br7seg

  . = 0x0000000800000000;
  .br8 : ALIGN(0x1000)
  {
    *(.branch8)
    *(.br8)
  } :br8seg

  . = ALIGN(0x1000);
  .data :
  {
    *(.data .data.*)
  } :data

  .bss :
  {
    *(.bss .bss.* COMMON)
  } :data
}