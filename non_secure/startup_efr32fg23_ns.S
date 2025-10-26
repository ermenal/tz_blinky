/*
 * Startup file for the NON-SECURE world (EFR32FG23)
 */
.syntax unified
.arch armv8-m.main

/* Non-Secure Stack */
.section .stack_ns, "w", %progbits
.align 3
.equ    Stack_Size_NS, 2048
.globl  __StackTop_NS
.globl  __StackLimit_NS
__StackLimit_NS:
.space  Stack_Size_NS
.size   __StackLimit_NS,. - __StackLimit_NS
__StackTop_NS:
.size .stack_ns,. -.stack_ns

/* Non-Secure Vector Table */
.section .isr_vector_ns, "a", %progbits
.align 2
.globl __isr_vector_ns
__isr_vector_ns:
.long   __StackTop_NS         /* Top of Non-Secure Stack */
.long   Reset_Handler_NS      /* Non-Secure Reset Handler */

.text
.thumb
.thumb_func
.align 2
.globl  Reset_Handler_NS
.type   Reset_Handler_NS, %function
Reset_Handler_NS:
  /*
   * This is the non-secure Reset_Handler_NS.
   * It performs the standard C runtime initialization.
   */

  /* Copy data from Flash to RAM */
  ldr   r1, =__etext_ns
  ldr   r2, =__data_start_ns__
  ldr   r3, =__data_end_ns__
  subs  r3, r2
  ble .L_zero_bss_ns

.L_copy_data_ns:
  subs  r3, 4
  ldr   r0, [r1, r3]
  str   r0, [r2, r3]
  bgt .L_copy_data_ns

.L_zero_bss_ns:
  /* Zero out the.bss section */
  ldr   r2, =__bss_start_ns__
  ldr   r3, =__bss_end_ns__
  subs  r3, r2
  ble .L_call_main_ns

  movs  r0, 0
.L_zero_loop_ns:
  subs  r3, 4
  str   r0, [r2, r3]
  bgt .L_zero_loop_ns

.L_call_main_ns:
  /* Call non-secure main */
  bl    main_ns

.L_loop:
  b .L_loop

.size Reset_Handler_NS,. - Reset_Handler_NS