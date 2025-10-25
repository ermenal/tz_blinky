#include "../common/nsc_api.h"
#include <stdint.h>

// Simple software delay
void delay(volatile uint32_t count)
{
  while(count--);
}

int main(void)
{
  while(1)
  {
    Secure_ToggleLED();
    delay(50000);
  }
}