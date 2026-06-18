.text
.align 2

.global aligned_site_k8
.type aligned_site_k8, %function
.p2align 8, 0xD503201F
aligned_site_k8:  nop; ret
.size aligned_site_k8, .-aligned_site_k8

.global aligned_site_k12
.type aligned_site_k12, %function
.p2align 12, 0xD503201F
aligned_site_k12: nop; ret
.size aligned_site_k12, .-aligned_site_k12

.global aligned_site_k20
.type aligned_site_k20, %function
.p2align 20, 0xD503201F
aligned_site_k20: nop; ret
.size aligned_site_k20, .-aligned_site_k20

.global aligned_site_k28
.type aligned_site_k28, %function
.p2align 28, 0xD503201F      // 256 MiB
aligned_site_k28: nop; ret
.size aligned_site_k28, .-aligned_site_k28


