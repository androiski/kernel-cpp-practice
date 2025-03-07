# **1. Set Up Your Development Environment**

Since you’re using **Arch Linux**, install the required tools:

```sh
sudo pacman -Syu base-devel git qemu nasm xorriso \
binutils gcc make flex bison libelf bc cpio perl clang llvm lld
```

✔️ `qemu` → Virtual machine emulator for testing.  
✔️ `binutils, gcc` → Compiler toolchain.  
✔️ `nasm` → Assembler for low-level boot code.  
✔️ `xorriso` → Required for creating bootable ISOs.  
✔️ `flex, bison, libelf` → Needed for kernel compilation.

---

# **2️. Create a Project Directory**

```sh
mkdir -p ~/projects/kernel_dev
cd ~/projects/kernel_dev
```

---

# **3. Write a Minimal Kernel in C++**

## **1. Write a Minimal Bootloader (`boot.s`)**

📄 **Create `boot.s`**

```assembly
section .multiboot
align 4
multiboot_header:
    dd 0x1BADB002                ; Magic number
    dd 0x0                       ; Flags
    dd -(0x1BADB002 + 0x0)       ; Checksum

section .bss
align 16
stack_bottom:
    resb 16384                   ; 16 KB stack
stack_top:

section .text
global _start
extern kernel_main

_start:
    mov esp, stack_top           ; Set up stack
    call kernel_main             ; Call the C++ kernel function
    hlt                          ; Halt CPU

```

---

## **2. Write a Simple Kernel in C++ (`kernel.cpp`)**

📄 **Create `kernel.cpp`**

```cpp
extern "C" void kernel_main() {
    char* video_memory = (char*)0xb8000;
    const char* message = "Hello, Kernel!";
    
    for (int i = 0; message[i] != '\0'; i++) {
        video_memory[i * 2] = message[i];       // Character
        video_memory[i * 2 + 1] = (char)0x07;   // White text on black background
    }
}
```

---

## **3. Create a Linker Script (`link.ld`)**

📄 **Create `link.ld`**

```ld
ENTRY(_start)

PHDRS {
    text PT_LOAD FLAGS(5);  /* Read + Execute */
    rodata PT_LOAD FLAGS(4);  /* Read-only */
    data PT_LOAD FLAGS(6);  /* Read + Write */
    bss PT_LOAD FLAGS(6);  /* Read + Write */
}

SECTIONS {
    . = 1M; /* Load kernel at 1MB */

    .multiboot ALIGN(4) : {
        *(.multiboot)
    } :text

    .text ALIGN(4) : {
        *(.text)
    } :text

    .rodata ALIGN(4) : {
        *(.rodata)
    } :rodata

    .data ALIGN(4) : {
        *(.data)
    } :data

    .bss ALIGN(4) : {
        *(COMMON)
        *(.bss)
    } :bss
}

```

---

# **4. Compile Everything**

## **1. Assemble the Bootloader**

```sh
nasm -f elf32 boot.s -o boot.o
```

## **2. Compile the Kernel (C++ to Object File)**

```sh
g++ -m32 -ffreestanding -nostdlib -c kernel.cpp -o kernel.o
```

✔️ `-m32` → Compile for 32-bit x86.  
✔️ `-ffreestanding` → Exclude the standard C++ runtime.  
✔️ `-nostdlib` → Prevent linking to system libraries.

## **3. Link Everything into a Kernel**

```sh
ld -m elf_i386 -T link.ld -o kernel.elf boot.o kernel.o
```

✔️ This creates a final kernel file `kernel.elf`.

---

# **5. Test the Kernel in QEMU**

Run:

```sh
qemu-system-i386 -kernel kernel.elf -m 256M -no-reboot -no-shutdown
```

✅ If successful, you should see **"Hello, Kernel!"** displayed in the emulator.
![Pasted image 20250307162000](https://github.com/user-attachments/assets/1df2c5ae-53e3-47a7-bbfb-b8293a4cdc91)
