#include <stdint.h>
#include "../common/nsc_api.h" // Contains Secure_LED_Init prototype
#include "Device/Include/efr32fg23b010f512im48.h"
#include "Core/Include/cmsis_gcc.h"

// Address of the Non-Secure vector table
#define NS_VTOR_ADDRESS 0x08020000

// Non-secure function pointer type
typedef void (*ns_func_ptr)(void) __attribute__((cmse_nonsecure_call));

int main(void)
{
  // Initialize secure peripherals
  Secure_LED_Init();

  // Set the Non-Secure Vector Table Offset Register
  SCB_NS->VTOR = NS_VTOR_ADDRESS;

  // Read the Non-Secure stack pointer and reset handler address
  uint32_t ns_stack_ptr = *((uint32_t *)NS_VTOR_ADDRESS);
  ns_func_ptr ns_reset_handler = (ns_func_ptr)(*((uint32_t *)(NS_VTOR_ADDRESS + 4)));

  // Set the Non-Secure stack pointer
  __TZ_set_MSP_NS(ns_stack_ptr);

  // Branch to the Non-Secure reset handler
  ns_reset_handler();

  while(1); // Should not be reached
}