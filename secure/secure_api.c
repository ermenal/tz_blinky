#include <arm_cmse.h>
#include "Device/Include/efr32fg23b010f512im48.h"

#define LED_PORT 1
#define LED_PIN  2

__attribute__((cmse_nonsecure_entry))
void Secure_ToggleLED(void)
{
  // Toggle the output of pin PB02
  GPIO->P_TGL[LED_PORT].DOUT = (1UL << LED_PIN);
}