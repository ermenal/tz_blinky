/*
 * Linker script for the non-secure application
 */

ENTRY(Reset_Handler_NS)

MEMORY
{
  FLASH_NS (rx)  : ORIGIN = 0x08020000, LENGTH = 384K
  RAM_NS   (rwx) : ORIGIN = 0x20008000, LENGTH = 32K
}

SECTIONS
{
  /* The startup code goes first into FLASH */
.isr_vector_ns :
  {
  . = ALIGN(4);
    KEEP(*(.isr_vector_ns)) /* Startup code */
  . = ALIGN(4);
  } >FLASH_NS

  /* The program code and other data goes into FLASH */
.text :
  {
  . = ALIGN(4);
    *(.text*)
    *(.rodata*)
  . = ALIGN(4);
  } >FLASH_NS

.ARM.extab   : { *(.ARM.extab*.gnu.linkonce.armextab.*) } >FLASH_NS
__exidx_start_ns =.;
.ARM.exidx   :
  {
    *(.ARM.exidx*.gnu.linkonce.armexidx.*)
  } >FLASH_NS
__exidx_end_ns =.;

  __etext_ns =.;    /* define a global symbol at end of code */

  /* Initialized data sections goes into RAM, load LMA copy after code */
.data :
  {
  . = ALIGN(4);
    __data_start_ns__ =.;   /* create a global symbol at data start */
    *(.data*)           /*.data sections */
    *(.data.*)          /*.data* sections */
  . = ALIGN(4);
    __data_end_ns__ =.;   /* define a global symbol at data end */
  } >RAM_NS AT> FLASH_NS

  /* Uninitialized data section */
.bss :
  {
  . = ALIGN(4);
    __bss_start_ns__ =.;
    *(.bss*)
    *(COMMON)
  . = ALIGN(4);
    __bss_end_ns__ =.;
  } >RAM_NS

._user_stack_ns (NOLOAD):
  {
  . = ALIGN(8);
    KEEP(*(.stack_ns))
  . = ALIGN(8);
  } >RAM_NS
}