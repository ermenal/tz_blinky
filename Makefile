# ==============================================================================
# Makefile for a Bare-Metal ARM TrustZone Project (EFR32FG23)
# ==============================================================================

# --- Toolchain Configuration ---
TARGET_PREFIX   := arm-none-eabi-
CC              := $(TARGET_PREFIX)gcc
AS              := $(TARGET_PREFIX)as
OBJCOPY         := $(TARGET_PREFIX)objcopy
SRECCAT         := srec_cat

# --- Build Directory ---
BUILD_DIR       := build

# --- Source Files ---
# Secure World Sources
SECURE_C_SOURCES      := $(wildcard secure/*.c)
SECURE_ASM_SOURCES    := $(wildcard secure/*.S)
SECURE_OBJS           := $(patsubst secure/%.c, $(BUILD_DIR)/secure/%.o, $(SECURE_C_SOURCES))
SECURE_OBJS           += $(patsubst secure/%.S, $(BUILD_DIR)/secure/%.o, $(SECURE_ASM_SOURCES))

# Non-Secure World Sources
NON_SECURE_C_SOURCES  := $(wildcard non_secure/*.c)
NON_SECURE_ASM_SOURCES:= $(wildcard non_secure/*.S)
NON_SECURE_OBJS       := $(patsubst non_secure/%.c, $(BUILD_DIR)/non_secure/%.o, $(NON_SECURE_C_SOURCES))
NON_SECURE_OBJS       += $(patsubst non_secure/%.S, $(BUILD_DIR)/non_secure/%.o, $(NON_SECURE_ASM_SOURCES))

# --- Compiler and Linker Flags ---
# Common flags for both worlds
CPU_FLAGS       := -mcpu=cortex-m33 -mthumb
COMMON_CFLAGS   := $(CPU_FLAGS) -g3 -Wall -O0 -ffunction-sections -fdata-sections -fno-exceptions 
COMMON_LDFLAGS  := $(CPU_FLAGS) -Wl,--gc-sections,--no-warn-rwx-segments -nostdlib --specs=nano.specs

# Secure World Flags
CFLAGS_S        := $(COMMON_CFLAGS) -mcmse -Icommon -Isecure
LDFLAGS_S       := $(COMMON_LDFLAGS) -Tsecure/secure.ld -Wl,-Map=$(BUILD_DIR)/secure.map

# Non-Secure World Flags
CFLAGS_NS       := $(COMMON_CFLAGS) -Icommon -Inon_secure
LDFLAGS_NS      := $(COMMON_LDFLAGS) -Tnon_secure/non_secure.ld -Wl,-Map=$(BUILD_DIR)/non_secure.map

# --- Output Files ---
# Secure World Outputs
SECURE_ELF      := $(BUILD_DIR)/secure.elf
SECURE_HEX      := $(BUILD_DIR)/secure.hex
SECURE_LIB      := $(BUILD_DIR)/secure_cmse_lib.o

# Non-Secure World Outputs
NON_SECURE_ELF  := $(BUILD_DIR)/non_secure.elf
NON_SECURE_HEX  := $(BUILD_DIR)/non_secure.hex

# Final Merged Output
FINAL_HEX       := $(BUILD_DIR)/final.hex

# ==============================================================================
# Build Targets
# ==============================================================================

.PHONY: all clean flash

# Default target: build everything
all: $(FINAL_HEX)

# --- Secure World Build Rules ---

# Link the secure ELF and, crucially, generate the secure import library
$(SECURE_ELF): $(SECURE_OBJS)
	@echo "Linking Secure ELF: $@"
	$(CC) $(LDFLAGS_S) $^ -o $@ -Wl,--out-implib=$(SECURE_LIB)

# Compile secure C files
$(BUILD_DIR)/secure/%.o: secure/%.c
	@mkdir -p $(@D)
	@echo "Compiling Secure C: $<"
	$(CC) $(CFLAGS_S) -c $< -o $@

# Assemble secure assembly files
$(BUILD_DIR)/secure/%.o: secure/%.S
	@mkdir -p $(@D)
	@echo "Assembling Secure ASM: $<"
	$(CC) $(CFLAGS_S) -c $< -o $@

# --- Non-Secure World Build Rules ---

# Link the non-secure ELF, using the secure import library as an input
$(NON_SECURE_ELF): $(NON_SECURE_OBJS) $(SECURE_ELF)
	@echo "Linking Non-Secure ELF: $@"
	$(CC) $(LDFLAGS_NS) $(NON_SECURE_OBJS) $(SECURE_LIB) -o $@

# Compile non-secure C files
$(BUILD_DIR)/non_secure/%.o: non_secure/%.c
	@mkdir -p $(@D)
	@echo "Compiling Non-Secure C: $<"
	$(CC) $(CFLAGS_NS) -c $< -o $@

# Assemble non-secure assembly files
$(BUILD_DIR)/non_secure/%.o: non_secure/%.S
	@mkdir -p $(@D)
	@echo "Assembling Non-Secure ASM: $<"
	$(CC) $(CFLAGS_NS) -c $< -o $@

# --- Conversion and Merging Rules ---

# Convert secure ELF to HEX
$(SECURE_HEX): $(SECURE_ELF)
	@echo "Converting to HEX: $<"
	$(OBJCOPY) -O ihex $< $@

# Convert non-secure ELF to HEX
$(NON_SECURE_HEX): $(NON_SECURE_ELF)
	@echo "Converting to HEX: $<"
	$(OBJCOPY) -O ihex $< $@

# Merge the two HEX files into a single file for flashing
$(FINAL_HEX): $(SECURE_HEX) $(NON_SECURE_HEX)
	@echo "Merging HEX files into: $@"
	$(SRECCAT) $(SECURE_HEX) -intel $(NON_SECURE_HEX) -intel -o $@ -intel

# --- Utility Targets ---

# Flash the final merged binary to the target
flash: all
	@echo "Flashing $(FINAL_HEX) to target..."
	JLinkExe -CommandFile flash.jlink

# Clean up all build artifacts
clean:
	@echo "Cleaning build directory..."
	rm -rf $(BUILD_DIR)