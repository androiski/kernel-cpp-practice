extern "C" void kernel_main() {
    char* video_memory = (char*)0xb8000;
    const char* message = "Hello, Kernel!";
    
    for (int i = 0; message[i] != '\0'; i++) {
        video_memory[i * 2] = message[i];       // Character
        video_memory[i * 2 + 1] = (char)0x07;   // White text on black background
    }
}
