                .syntax  unified
                .arch    armv8-m.main

// stack_ns sectie begint
                .section    .stack_ns
                .align      9
// Bepaal stack_ns size (meegegeven of kies zelf 0x00000400)
                #ifdef __STACK_SIZE
                .equ        Stack_ns_Size, __STACK_SIZE
                #else
                .equ        Stack_ns_Size, 0x00000400
                #endif
// Def globals (__StackTopNS en __StackLimitNS zijn bruikbaar buiten deze file) 
                .globl      __StackTopNS
                .globl      __StackLimitNS
                __StackLimitNS:
// Bewaar __Stack_ns_Size plaats om later in te vullen met stack
                .space      Stack_ns_Size
                .size       __StackLimitNS, . - __StackLimitNS
// Zet stack zn size als Top - StackLimit - alignment (stack groeit naar beneden in M33)
 __StackTopNS:
                .size       __StackTopNS, . - __StackTopNS

// heap_ns sectie begint, similar als stack
                .section    .heap_ns
                .align      3
                #ifdef __HEAP_SIZE
                .equ        Heap_SizeNS, __HEAP_SIZE
                #else
                .equ        Heap_SizeNS, 0x00000C00
                #endif
                .globl      __HeapBaseNS
                .globl      __HeapLimitNS
 __HeapBaseNS:
                .if Heap_SizeNS // ahhh als we __HEAP_SIZE = 0 meegeven
                .space      Heap_SizeNS
                .endif
                .size       __HeapBaseNS, . - __HeapBaseNS
 __HeapLimitNS:
                .size       __HeapLimitNS, . - __HeapLimitNS

// Definieer waar we beginnen met NSW execution
#define __INITIAL_SP_NS     __StackTopNS
                #if defined(SL_TRUSTZONE_SECURE) // Niet het geval ?
#define __STACK_LIMIT_NS    __StackLimitNS
                #if defined (__ARM_FEATURE_CMSE) && (__ARM_FEATURE_CMSE == 3U)
#define __STACK_SEAL_NS     __StackSeal // Wel het geval? 
                #endif
                #endif // SL_TRUSTZONE_SECURE

// Begin vectors_ns sectie. 
// Ik doe enkel initial sp en reset handler voorlopig
                .section .vectors_ns
                .align   2
                .globl   __Vectors_NS
                .globl   __Vectors_NS_End
                .globl   __Vectors_NS_Size
__Vectors_NS:
                .long    __INITIAL_SP_NS                       /*     Initial Stack Pointer */
                .long    Reset_Handler_ns                      /*     Reset Handler */
            /*
                .long    NMI_Handler                        
                .long    HardFault_Handler                  
                .long    MemManage_Handler                  
                .long    BusFault_Handler                   
                .long    UsageFault_Handler                 
                .long    SecureFault_Handler                
                .long    Default_Handler                    
                .long    Default_Handler                    
                .long    Default_Handler                    
                .long    SVC_Handler                        
                .long    DebugMon_Handler                   
                .long    sl_app_properties                  
                .long    PendSV_Handler                     
                .long    SysTick_Handler 
             */
             /* External interrupts komen hier, nu geen enkele */

/* calculate the empty space according the used Cortex-Core */
                .space   (480 * 4)  /* Geen enkele vd 480 external interrupts gebruikt */
                // Tbh idk hoe belangrijk deze space laten is
__Vectors_NS_End:
                .equ     __Vectors_NS_Size, __Vectors_NS_End - __Vectors_NS
                .size    __Vectors_NS, . - __Vectors_NS

// begin .text_ns section
                .thumb
                .section .text_ns
                .align   2

// NS Reset Handler, moet naar ns main springen
                .thumb_func
                .type    Reset_Handler_ns, %function
                .globl   Reset_Handler_ns
                .fnstart
Reset_Handler_ns:
                #if defined (SL_TRUSTZONE_SECURE) // Niet
                ldr      r0, =__STACK_LIMIT_NS
                msr      msplim, r0

                #if defined (__ARM_FEATURE_CMSE) && (__ARM_FEATURE_CMSE == 3U)
                ldr      r0, =__STACK_SEAL_NS // Wel ? Maar binnen secure dus niet?
                ldr      r1, =0xFEF5EDA5U
                strd     r1,r1,[r0,#0]
                #endif
                #endif // SL_TRUSTZONE_SECURE
// SysInit al gebeurd door SW
//                bl       SystemInit

// TODO: Vind uit waar copy_table goed voor is
                ldr      r4, =__copy_table_ns_start__
                ldr      r5, =__copy_table_ns_end__

.L_loop0_ns:
                cmp      r4, r5
                bge      .L_loop0_done_ns // Alles gekopieerd, copy_table_start == copy_table_end
                ldr      r1, [r4]                /* source address */
                ldr      r2, [r4, #4]            /* destination address */
                ldr      r3, [r4, #8]            /* word count */
                lsls     r3, r3, #2              /* byte count */

.L_loop0_0_ns:
                subs     r3, #4                  /* decrement byte count */
                ittt     ge
                ldrge    r0, [r1, r3]
                strge    r0, [r2, r3]
                bge      .L_loop0_0_ns

                adds     r4, #12
                b        .L_loop0_ns
.L_loop0_done_ns:

                ldr      r3, =__zero_table_start__
                ldr      r4, =__zero_table_end__

.L_loop2_ns:
                cmp      r3, r4
                bge      .L_loop2_done_ns
                ldr      r1, [r3]                /* destination address */
                ldr      r2, [r3, #4]            /* word count */
                lsls     r2, r2, #2              /* byte count */
                movs     r0, 0

.L_loop2_0_ns:
                subs     r2, #4                  /* decrement byte count */
                itt      ge
                strge    r0, [r1, r2]
                bge      .L_loop2_0_ns

                adds     r3, #8
                b        .L_loop2_ns
.L_loop2_done_ns: // Start program nadat loop2 gedaan is

                bl main_ns // Als __START wel gedefined is somehow

                .fnend
                .size    Reset_Handler_ns, . - Reset_Handler_ns
/* The default macro is not used for HardFault_Handler
 * because this results in a poor debug illusion.
 */
// Skip deze 2 ook voorlopig
/*
                .thumb_func
                .type    HardFault_Handler, %function
                .weak    HardFault_Handler
                .fnstart

/*
HardFault_Handler:
                b        .
                .fnend
                .size    HardFault_Handler, . - HardFault_Handler

                .thumb_func
                .type    Default_Handler, %function
                .weak    Default_Handler
                .fnstart
Default_Handler:
                b        .
                .fnend
                .size    Default_Handler, . - Default_Handler
*/


// Skip deze voorlopig nog

/* Macro to define default exception/interrupt handlers.
 * Default handler are weak symbols with an endless loop.
 * They can be overwritten by real handlers.
 */
 /*
                .macro   Set_Default_Handler  Handler_Name
                .weak    \Handler_Name
                .set     \Handler_Name, Default_Handler
                .endm
                Set_Default_Handler  NMI_Handler
                Set_Default_Handler  MemManage_Handler
                Set_Default_Handler  BusFault_Handler
                Set_Default_Handler  UsageFault_Handler
                Set_Default_Handler  SecureFault_Handler
                Set_Default_Handler  SVC_Handler
                Set_Default_Handler  DebugMon_Handler
                Set_Default_Handler  sl_app_properties
                Set_Default_Handler  PendSV_Handler
                Set_Default_Handler  SysTick_Handler
                Set_Default_Handler  SMU_SECURE_IRQHandler
                Set_Default_Handler  SMU_S_PRIVILEGED_IRQHandler
                Set_Default_Handler  SMU_NS_PRIVILEGED_IRQHandler
                Set_Default_Handler  EMU_IRQHandler
                Set_Default_Handler  TIMER0_IRQHandler
                Set_Default_Handler  TIMER1_IRQHandler
                Set_Default_Handler  TIMER2_IRQHandler
                Set_Default_Handler  TIMER3_IRQHandler
                Set_Default_Handler  TIMER4_IRQHandler
                Set_Default_Handler  USART0_RX_IRQHandler
                Set_Default_Handler  USART0_TX_IRQHandler
                Set_Default_Handler  EUSART0_RX_IRQHandler
                Set_Default_Handler  EUSART0_TX_IRQHandler
                Set_Default_Handler  EUSART1_RX_IRQHandler
                Set_Default_Handler  EUSART1_TX_IRQHandler
                Set_Default_Handler  EUSART2_RX_IRQHandler
                Set_Default_Handler  EUSART2_TX_IRQHandler
                Set_Default_Handler  ICACHE0_IRQHandler
                Set_Default_Handler  BURTC_IRQHandler
                Set_Default_Handler  LETIMER0_IRQHandler
                Set_Default_Handler  SYSCFG_IRQHandler
                Set_Default_Handler  MPAHBRAM_IRQHandler
                Set_Default_Handler  LDMA_IRQHandler
                Set_Default_Handler  LFXO_IRQHandler
                Set_Default_Handler  LFRCO_IRQHandler
                Set_Default_Handler  ULFRCO_IRQHandler
                Set_Default_Handler  GPIO_ODD_IRQHandler
                Set_Default_Handler  GPIO_EVEN_IRQHandler
                Set_Default_Handler  I2C0_IRQHandler
                Set_Default_Handler  I2C1_IRQHandler
                Set_Default_Handler  EMUDG_IRQHandler
                Set_Default_Handler  AGC_IRQHandler
                Set_Default_Handler  BUFC_IRQHandler
                Set_Default_Handler  FRC_PRI_IRQHandler
                Set_Default_Handler  FRC_IRQHandler
                Set_Default_Handler  MODEM_IRQHandler
                Set_Default_Handler  PROTIMER_IRQHandler
                Set_Default_Handler  RAC_RSM_IRQHandler
                Set_Default_Handler  RAC_SEQ_IRQHandler
                Set_Default_Handler  HOSTMAILBOX_IRQHandler
                Set_Default_Handler  SYNTH_IRQHandler
                Set_Default_Handler  ACMP0_IRQHandler
                Set_Default_Handler  ACMP1_IRQHandler
                Set_Default_Handler  WDOG0_IRQHandler
                Set_Default_Handler  WDOG1_IRQHandler
                Set_Default_Handler  HFXO0_IRQHandler
                Set_Default_Handler  HFRCO0_IRQHandler
                Set_Default_Handler  HFRCOEM23_IRQHandler
                Set_Default_Handler  CMU_IRQHandler
                Set_Default_Handler  AES_IRQHandler
                Set_Default_Handler  IADC_IRQHandler
                Set_Default_Handler  MSC_IRQHandler
                Set_Default_Handler  DPLL0_IRQHandler
                Set_Default_Handler  EMUEFP_IRQHandler
                Set_Default_Handler  DCDC_IRQHandler
                Set_Default_Handler  VDAC_IRQHandler
                Set_Default_Handler  PCNT0_IRQHandler
                Set_Default_Handler  SW0_IRQHandler
                Set_Default_Handler  SW1_IRQHandler
                Set_Default_Handler  SW2_IRQHandler
                Set_Default_Handler  SW3_IRQHandler
                Set_Default_Handler  KERNEL0_IRQHandler
                Set_Default_Handler  KERNEL1_IRQHandler
                Set_Default_Handler  M33CTI0_IRQHandler
                Set_Default_Handler  M33CTI1_IRQHandler
                Set_Default_Handler  FPUEXH_IRQHandler
                Set_Default_Handler  SETAMPERHOST_IRQHandler
                Set_Default_Handler  SEMBRX_IRQHandler
                Set_Default_Handler  SEMBTX_IRQHandler
                Set_Default_Handler  LESENSE_IRQHandler
                Set_Default_Handler  SYSRTC_APP_IRQHandler
                Set_Default_Handler  SYSRTC_SEQ_IRQHandler
                Set_Default_Handler  LCD_IRQHandler
                Set_Default_Handler  KEYSCAN_IRQHandler
                Set_Default_Handler  RFECA0_IRQHandler
                Set_Default_Handler  RFECA1_IRQHandler

*/
                .end
