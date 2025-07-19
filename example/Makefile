LIBPATH = /afs/ece.cmu.edu/usr/aryllp/Private/xpack-riscv-none-elf-gcc-14.2.0-3/bin
run: address = $(strip $(subst 0x,, $(shell cat start_addr.txt)))
run: mem_size = $(shell cat mem_addr.txt)
run: data_addr = $(shell cat data_addr.txt)
run: data_size = $(shell cat data_size.txt)
run: sdata_addr = $(shell cat sdata_addr.txt)
run: sdata_size = $(shell cat sdata_size.txt)
run: bss_addr = $(shell cat bss_addr.txt)
run: bss_size = $(shell cat bss_size.txt)
run: sbss_addr = $(shell cat sbss_addr.txt)
run: sbss_size = $(shell cat sbss_size.txt)

run: parse
	rm mem_addr.txt
	rm start_addr.txt
	rm data_addr.txt
	rm data_size.txt
	rm sdata_addr.txt
	rm sdata_size.txt
	rm bss_addr.txt
	rm bss_size.txt
	rm sbss_addr.txt
	rm sbss_size.txt
	cd ..; ./simv +MEM_SIZE=$(mem_size) +START_ADDRESS=$(address) \
		+DATA_ADDRESS=$(data_addr) +DATA_SIZE=$(data_size) \
		+SDATA_ADDRESS=$(sdata_addr) +SDATA_SIZE=$(sdata_size) \
		+BSS_ADDRESS=$(bss_addr) +BSS_SIZE=$(bss_size) \
		+SBSS_ADDRESS=$(sbss_addr) +SBSS_SIZE=$(sbss_size) \
		+VERBOSE

parse: objdump.txt example_raw.txt
	awk '{print $$2, $$3, $$4, $$5, $$6, $$7}' example_raw.txt > example.txt
	awk '{if(NR == 6) print $$3}' objdump.txt > start_addr.txt
	awk '{if(NR == 20) print $$4}' objdump.txt > mem_addr.txt
	awk '{if(NR > 20 && $$2 == ".data") print $$4}' objdump.txt > data_addr.txt
	awk '{if(NR > 20 && $$2 == ".data") print $$3}' objdump.txt > data_size.txt
	awk '{if(NR > 20 && $$2 == ".sdata") print $$4}' objdump.txt > sdata_addr.txt
	awk '{if(NR > 20 && $$2 == ".sdata") print $$3}' objdump.txt > sdata_size.txt
	awk '{if(NR > 20 && $$2 == ".bss") print $$4}' objdump.txt > bss_addr.txt
	awk '{if(NR > 20 && $$2 == ".bss") print $$3}' objdump.txt > bss_size.txt
	awk '{if(NR > 20 && $$2 == ".sbss") print $$4}' objdump.txt > sbss_addr.txt
	awk '{if(NR > 20 && $$2 == ".sbss") print $$3}' objdump.txt > sbss_size.txt

objdump.txt example_raw.txt: example.c
	$(LIBPATH)/riscv-none-elf-gcc -march=rv32i --specs=nano.specs example.c -o example.out
	$(LIBPATH)/riscv-none-elf-objdump -x example.out > objdump.txt
	$(LIBPATH)/riscv-none-elf-objdump -d example.out > asm.txt
	$(LIBPATH)/riscv-none-elf-objcopy -O binary example.out example.bin
	xxd -b example.bin > example_raw.txt
	rm example.out
	rm example.bin

clean:
ifneq ("$(wildcard example.out)","")
	rm example.out
endif
ifneq ("$(wildcard example.bin)","")
	rm example.bin
endif
ifneq ("$(wildcard example.txt)","")
	rm example.txt
endif
ifneq ("$(wildcard start_addr.txt)","")
	rm start_addr.txt
endif
ifneq ("$(wildcard mem_addr.txt)","")
	rm mem_addr.txt
endif
ifneq ("$(wildcard objdump.txt)","")
	rm objdump.txt
endif
ifneq ("$(wildcard example_raw.txt)","")
	rm example_raw.txt
endif
ifneq ("$(wildcard asm.txt)","")
	rm asm.txt
endif
ifneq ("$(wildcard data_addr.txt)","")
	rm data_addr.txt
endif
ifneq ("$(wildcard data_size.txt)","")
	rm data_size.txt
endif
ifneq ("$(wildcard sdata_addr.txt)","")
	rm sdata_addr.txt
endif
ifneq ("$(wildcard sdata_size.txt)","")
	rm sdata_size.txt
endif
ifneq ("$(wildcard bss_addr.txt)","")
	rm bss_addr.txt
endif
ifneq ("$(wildcard bss_size.txt)","")
	rm bss_size.txt
endif
ifneq ("$(wildcard sbss_addr.txt)","")
	rm sbss_addr.txt
endif
ifneq ("$(wildcard sbss_size.txt)","")
	rm sbss_size.txt
endif


	


	
