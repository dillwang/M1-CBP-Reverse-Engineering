.data
.align 3
hex_tbl: .ascii "0123456789abcdef"

.bss
.align 3
outbuf: .skip 96

.text
.align 2

.macro SYS_WRITE fd, buf, len
  mov x0, \fd
  mov x1, \buf
  mov x2, \len
  mov x8, #64
  svc #0
.endm

.macro SYS_EXIT code
  mov x0, \code
  mov x8, #93
  svc #0
.endm

.global u64_to_hex
.type u64_to_hex, %function
u64_to_hex:
  stp x29, x30, [sp, -16]!
  mov x29, sp

  adrp x4, hex_tbl
  add  x4, x4, :lo12:hex_tbl

  mov x2, #60
1:
  lsr x3, x1, x2
  and x3, x3, #0xf
  ldrb w5, [x4, x3]
  strb w5, [x0], #1
  subs x2, x2, #4
  b.ge 1b

  ldp x29, x30, [sp], 16
  ret
.size u64_to_hex, .-u64_to_hex

.section .text0, "ax"
.global site_A
.type site_A, %function
site_A:
  nop
  ret
.size site_A, .-site_A

.section .text1, "ax"
.global site_B
.type site_B, %function
site_B:
  nop
  ret
.size site_B, .-site_B

.section .text.startup, "ax"
.global _start
.type _start, %function
_start:
  ldr x20, =site_A
  ldr x21, =site_B
  sub x22, x21, x20

  adrp x10, outbuf
  add  x10, x10, :lo12:outbuf
  mov  x11, x10

  mov  w0, #'A'
  strb w0, [x11], #1
  mov  w0, #'='
  strb w0, [x11], #1
  mov  w0, #'0'
  strb w0, [x11], #1
  mov  w0, #'x'
  strb w0, [x11], #1
  mov  x0, x11
  mov  x1, x20
  bl   u64_to_hex
  add  x11, x11, #16
  mov  w0, #'\n'
  strb w0, [x11], #1

  mov  w0, #'B'
  strb w0, [x11], #1
  mov  w0, #'='
  strb w0, [x11], #1
  mov  w0, #'0'
  strb w0, [x11], #1
  mov  w0, #'x'
  strb w0, [x11], #1
  mov  x0, x11
  mov  x1, x21
  bl   u64_to_hex
  add  x11, x11, #16
  mov  w0, #'\n'
  strb w0, [x11], #1

  mov  w0, #'D'
  strb w0, [x11], #1
  mov  w0, #'='
  strb w0, [x11], #1
  mov  w0, #'0'
  strb w0, [x11], #1
  mov  w0, #'x'
  strb w0, [x11], #1
  mov  x0, x11
  mov  x1, x22
  bl   u64_to_hex
  add  x11, x11, #16
  mov  w0, #'\n'
  strb w0, [x11], #1

  sub x2, x11, x10
  SYS_WRITE 1, x10, x2

  bl site_A
  bl site_B

  SYS_EXIT 0
.size _start, .-_start
