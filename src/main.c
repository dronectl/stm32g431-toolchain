
#include "stm32g431xx.h"

static void __delay(uint64_t delay) {
  for (uint64_t i = 0; i < delay; i++) { __NOP(); };
}

int main(void) {
  // enable clock on port C gpio
  RCC->AHB1ENR |= RCC_AHB2ENR_GPIOCEN;

  // setup pin 6 of port C as output
  GPIOC->MODER |= GPIO_MODER_MODE6_0;

  // status blinker
  while (1) {
    GPIOC->BSRR |= (1 << 6);
    __delay(1000);
    GPIOC->BSRR |= (1 << (6 + 16));
    __delay(1000);
  }
}