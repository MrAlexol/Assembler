TARGET = hw1

help:
	@echo Available goals:
	@echo ' run       - create and run without debugging '
	@echo ' translate - create executable '
	@echo ' debug     - create and debug  '
	@echo ' help      - show this message '
$(TARGET): $(TARGET).asm main.asm
	nasm -f elf64 -l $(TARGET).lst $(TARGET).asm
	nasm -f elf64 -l main.lst main.asm
	ld -o $(TARGET) main.o $(TARGET).o 
run: $(TARGET)
	./$(TARGET)
debug: $(TARGET)
	edb --run $(TARGET)
translate: $(TARGET)
	@echo "\033[32mFile ${TARGET} is ready\033[0m"

