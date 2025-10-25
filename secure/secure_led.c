#include "Device/Include/efr32fg23b010f512im48.h"

// #define LED_PORT gpioPortB
#define LED_PORT 1
#define LED_PIN  2
#define PUSHPULL_MODE 4

void Secure_LED_Init(void)
{
  // Enable GPIO clock
  CMU->CLKEN0_SET = CMU_CLKEN0_GPIO;

  // Configure PB02 as push-pull output
//   GPIO->P_TGL = (GPIO->P.MODEL & ~_GPIO_P_MODEL_MODE2_Msk) | GPIO_P_MODEL_MODE2_PUSHPULL;

    // Toggle PB02
    // port b == 1, pin 2 voor led
    // GPIO->P_TGL[1].DOUT = 1UL << LED_PIN;
    GPIO->P[LED_PORT].MODEL = (GPIO->P[LED_PORT].MODEL & ~0xFu << LED_PIN*4) | (PUSHPULL_MODE << LED_PIN*4);

}