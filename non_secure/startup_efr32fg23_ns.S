/*
 * Startup file for the NON-SECURE world (EFR32FG23)
 */
.syntax unified
.arch armv8-m.main

/* Non-Secure Stack */
.section .stack, "w", %progbits
.align 3
.equ    Stack_Size, 2048
.globl  __StackTop
.globl  __StackLimit
__StackLimit:
 .space  Stack_Size
 .size   __StackLimit,. - __StackLimit
__StackTop:
 .size .stack,. -.stack

/* Non-Secure Vector Table */
.section .isr_vector, "a", %progbits
.align 2
.globl __isr_vector
__isr_vector:
 .long   __StackTop         /* Top of Non-Secure Stack */
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
   * This is the non-secure Reset_Handler_NS.
   * It performs the standard C runtime initialization.
   */

  /* Copy data from Flash to RAM */
  ldr   r1, =_etext
  ldr   r2, =_sdata
  ldr   r3, =_edata
  subs  r3, r2
  ble  .L_zero_bss

.L_copy_data:
  subs  r3, 4
  ldr   r0, [r1, r3]
  str   r0, [r2, r3]
  bgt  .L_copy_data

.L_zero_bss:
  /* Zero out the.bss section */
  ldr   r2, =_sbss
  ldr   r3, =_ebss
  subs  r3, r2
  ble  .L_call_main

  movs  r0, 0
.L_zero_loop:
  subs  r3, 4
  str   r0, [r2, r3]
  bgt  .L_zero_loop

.L_call_main:
  /* Call non-secure main */
  bl    main_ns

.L_loop:
  b .L_loop

.size Reset_Handler_NS,. - Reset_Handler_NS