EXE = read_crust1_to_3D
CC = gcc
FF = gfortran
INCDIR = ../inc
CFLAGS = -O3 -I$(INCDIR)
FFLAGS = -O3 -mcmodel=medium -I$(INCDIR)
USER_OBJ = read_crust1_to_3D.o

.PHONY: run clean
#run: $(EXE) ../tomo.inp
#	./$(EXE)
$(EXE): $(USER_OBJ)
	$(FF) $(FFLAGS) -o $@ *.o 
	./$(EXE)
%.o: %.c
	$(CC) $(CFLAGS) -c $<
%.o: %.f
	$(FF) $(FFLAGS) -c $<
%.o: %.f90
	$(FF) $(FFLAGS) -c $<
	
clean:
	rm -f *.o $(EXE)
