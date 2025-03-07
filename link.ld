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

