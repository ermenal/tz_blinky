/*
 * Linker script for the non-secure application
 */

ENTRY(Reset_Handler)

MEMORY
{
  FLASH_NS (rx)  : ORIGIN = 0x08020000, LENGTH = 384K
  RAM_NS   (rwx) : ORIGIN = 0x20008000, LENGTH = 32K
}

SECTIONS
{
.text :
  {
  . = ALIGN(4);
    KEEP(*(.isr_vector)) /* CRITICAL: Keep the vector table, the entry point */
    *(.text*)
    *(.rodata*)
  . = ALIGN(4);
  } > FLASH_NS

  _etext =.;

.data :
  {
  . = ALIGN(4);
    _sdata =.;
    *(.data*)
  . = ALIGN(4);
    _edata =.;
  } > RAM_NS AT> FLASH_NS

.bss :
  {
  . = ALIGN(4);
    _sbss =.;
    __bss_start__ = _sbss;
    *(.bss*)
    *(COMMON)
  . = ALIGN(4);
    _ebss =.;
    __bss_end__ = _ebss;
  } > RAM_NS

  /* Define symbols for heap start */
. = ALIGN(8);
  PROVIDE(end =.);
  PROVIDE(_end =.);

  /* Define a section for the non-secure stack */
._user_stack (NOLOAD):
  {
    KEEP(*(.stack))
  } > RAM_NS
}