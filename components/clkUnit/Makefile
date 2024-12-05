# GHDL=/mnt/n7fs/ens/tp_guivarch/opt2023/ghdl-2.0.0/bin/ghdl
GHDL=ghdl
GHDLFLAGS=-fsynopsys --std=08
MODULES=\
    clkUnit.o \
	diviseurClk1Hz.o \
	testClkUnit.o \
	testClkUnit

TIME=5000ns
PLOT=output

all: test clean

test: $(MODULES)
	$(GHDL) -r $(GHDLFLAGS) testClkUnit \
	--stop-time=${TIME} \
	--vcd=${PLOT}.vcd
       
# Binary depends on the object file
%: %.o
	$(GHDL) -e $(GHDLFLAGS) $@

# Object file depends on source
%.o: %.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

clean:
	echo "Cleaning up..."
	$(GHDL) --remove $(GHDLFLAGS)
#
#	rm -f ${PLOT}.vcd
