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
  /* Add other non-secure interrupt handlers here if needed */

.text
.thumb
.thumb_func
.align 2
.globl  Reset_Handler_NS
.type   Reset_Handler_NS, %function
Reset_Handler_NS:
  /*
   * The secure world has already performed the transition.
   * This handler's only job is to call the non-secure main function.
   * A more complex application would copy its own.data and zero its.bss here.
   */
  bl    main_ns

.L_loop_ns:
  b  .L_loop_ns

.size Reset_Handler_NS,. - Reset_Handler_NS