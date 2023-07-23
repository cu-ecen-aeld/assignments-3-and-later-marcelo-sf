ARM_CROSS_COMPILE ?= aarch64-none-linux-gnu-

all : writer 

writer:
ifeq ($(CROSS_COMPILE),aarch64-none-linux-gnu-)
	aarch64-none-linux-gnu-gcc -o writer writer.c
else
	gcc -o writer writer.c
endif

clean:
	rm -f writer.o writer
