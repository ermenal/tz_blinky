/**************************************************************************//**
 * @file     startup_efr32fg23.S
 * @brief    CMSIS-Core(M) Device Startup File for
 *           Device EFR32FG23
 *           Device EFR32FG23
 * @version  V2.3.0
 * @date     26. May 2021
 ******************************************************************************
 ******************************************************************************
 * # License
 *
 * The licensor of this software is Silicon Laboratories Inc. Your use of this
 * software is governed by the terms of Silicon Labs Master Software License
 * Agreement (MSLA) available at
 * www.silabs.com/about-us/legal/master-software-license-agreement. This
 * software is Third Party Software licensed by Silicon Labs from a third party
 * and is governed by the sections of the MSLA applicable to Third Party
 * Software and the additional terms set forth below.
 *
 *****************************************************************************/
/*
 * Copyright (c) 2009-2021 Arm Limited. All rights reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the License); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an AS IS BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

                .syntax  unified
                .arch    armv8-m.main

                .section    .stack
                .align      9
                #ifdef __STACK_SIZE
                .equ        Stack_Size, __STACK_SIZE
                #else
                .equ        Stack_Size, 0x00000400
                #endif
                .globl      __StackTop
                .globl      __StackLimit
                __StackLimit:
                .space      Stack_Size
                .size       __StackLimit, . - __StackLimit
 __StackTop:
                .size       __StackTop, . - __StackTop

                .section    .heap
                .align      3
                #ifdef __HEAP_SIZE
                .equ        Heap_Size, __HEAP_SIZE
                #else
                .equ        Heap_Size, 0x00000C00
                #endif
                .globl      __HeapBase
                .globl      __HeapLimit
 __HeapBase:
                .if Heap_Size
                .space      Heap_Size
                .endif
                .size       __HeapBase, . - __HeapBase
 __HeapLimit:
                .size       __HeapLimit, . - __HeapLimit

#define __INITIAL_SP     __StackTop
                #if defined(SL_TRUSTZONE_SECURE)
#define __STACK_LIMIT    __StackLimit
                #if defined (__ARM_FEATURE_CMSE) && (__ARM_FEATURE_CMSE == 3U)
#define __STACK_SEAL     __StackSeal
                #endif
                #endif // SL_TRUSTZONE_SECURE

.section .vectors_ns, "a", %progbits
.align 2
.globl vectors_ns
__Vectors_ns:
  .long   __StackTop      /* Top of Non-Secure Stack */
  .long   Reset_HandlerNS   /* Non-Secure Reset Handler */
.space (478 * 4)

__Vectors_ns_End:
                .equ     __Vectors_ns_Size, __Vectors_ns_End - __Vectors_ns
                .size    __Vectors_ns, . - __Vectors_ns

                .section .text
                .align   2

                .thumb_func
                .type    Reset_HandlerNS, %function
                .globl   Reset_HandlerNS
                .fnstart
Reset_HandlerNS:
                #if defined (SL_TRUSTZONE_SECURE)
                ldr      r0, =__STACK_LIMIT
                msr      msplim, r0

                #if defined (__ARM_FEATURE_CMSE) && (__ARM_FEATURE_CMSE == 3U)
                ldr      r0, =__STACK_SEAL
                ldr      r1, =0xFEF5EDA5U
                strd     r1,r1,[r0,#0]
                #endif
                #endif // SL_TRUSTZONE_SECURE

                //bl       SystemInit

                ldr      r4, =__copy_table_start__
                ldr      r5, =__copy_table_end__

.L_loop0:
                cmp      r4, r5
                bge      .L_loop0_done
                ldr      r1, [r4]                /* source address */
                ldr      r2, [r4, #4]            /* destination address */
                ldr      r3, [r4, #8]            /* word count */
                lsls     r3, r3, #2              /* byte count */

.L_loop0_0:
                subs     r3, #4                  /* decrement byte count */
                ittt     ge
                ldrge    r0, [r1, r3]
                strge    r0, [r2, r3]
                bge      .L_loop0_0

                adds     r4, #12
                b        .L_loop0
.L_loop0_done:

                ldr      r3, =__zero_table_start__
                ldr      r4, =__zero_table_end__

.L_loop2:
                cmp      r3, r4
                bge      .L_loop2_done
                ldr      r1, [r3]                /* destination address */
                ldr      r2, [r3, #4]            /* word count */
                lsls     r2, r2, #2              /* byte count */
                movs     r0, 0

.L_loop2_0:
                subs     r2, #4                  /* decrement byte count */
                itt      ge
                strge    r0, [r1, r2]
                bge      .L_loop2_0

                adds     r3, #8
                b        .L_loop2
.L_loop2_done:
                bl      main_ns

                .fnend
                .size    Reset_HandlerNS, . - Reset_HandlerNS
/* The default macro is not used for HardFault_Handler
 * because this results in a poor debug illusion.
 */

                .end
