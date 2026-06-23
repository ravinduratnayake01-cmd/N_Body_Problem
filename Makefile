# Makefile
# Main program file name
MAIN = Main

# Choose compiler
FC = gfortran

# Options and Path
FFLAGS = -O0 -fno-second-underscore -Wall -fbounds-check -fbacktrace -ffpe-trap=invalid,zero,overflow
# FFLAGS = -O3

# Final executable name 
EXEC = nbody.exe

##############################################################################
#----------------------------------------------------------------------------

#.MAKEOPTS: -k -s

.SUFFIXES: .f95

# Pattern rule to compile .f95 or .f90 -> .o
%.o: %.f95
	$(FC) $(FFLAGS) -c $< -o $@

# Use all .f95 files except the main file
MODULES = $(filter-out $(MAIN).f95, $(wildcard *.f95))

# Object files from modules
OBJ = $(MODULES:.f95=.o)

# OR
# Individual modules
#OBJ    = module1.o \
		 module2.o \

# Default rules
ALL: $(EXEC) PartialClean
	@echo "!!!        Compilation OK        !!!"

# Rule to compile the main and all the modules
$(EXEC): $(OBJ) $(MAIN).o
	$(FC) $(FFLAGS) $(OBJ) $(MAIN).o -o $(EXEC)

# Clean rules
PartialClean:
	rm -f *.o *.mod

clean:
	rm -f *.o *.mod $(EXEC)

# Show what is compiled
show:
	@echo "Main file: $(MAIN).f95"
	@echo "Modules: $(MODULES)"
	@echo "Objects: $(OBJ) $(MAIN).o"
	@echo "Executable: $(EXEC)"

.PHONY: ALL clean PartialClean show

##############################################################################
#----------------------------------------------------------------------------