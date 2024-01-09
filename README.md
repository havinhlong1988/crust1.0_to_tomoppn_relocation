# crust1.0_to_tomoppn_relocation
reading the output of crust1.0 model and make the 3D model for ppn-ssn relocation (huang et. al. 2013)

Job: Read the crust 1 coordinates and data to make 3D model for ppn-ssn relocation
----------------------------------------------------------------------------------
Job flow idea:
    1. read the coordinates list
    2. querry the lat - long - dep list (python)
    3. read the 1D layers cake model (crust1.0)
    4. 1D linear interpolation (python)
    5. Fit the coordinates with the data points
    6. Output model
----------------------------------------------------------------------------------
requerement:
    + fortran90
    + python3.8 (and based):
        * numpy
        * pandas
        * matplotlib
        * scipy
----------------------------------------------------------------------------------
input data: (contained in [input] directory)
    + coordinates data:
      #lat		lon 0.1x0.1
        19.5	98.5
        19.6	98.5
        19.7	98.5
        19.8	98.5
        19.9	98.5
    + output of crust1.0 program

            .... reading all maps ... 
        enter center lat, long of desired tile (q to quit)
        ilat,ilon,crustal type:   71 279
        topography:   0.939999998    
        layers: vp,vs,rho,bottom
        1.50   0.00   1.02   0.94
        3.81   1.94   0.92   0.94
        2.50   1.07   2.11   0.84
        0.00   0.00   0.00   0.84
        0.00   0.00   0.00   0.84
        6.10   3.55   2.74 -14.96
        6.30   3.65   2.78 -28.96
        7.00   3.99   2.95 -35.06
        pn,sn,rho-mantle:    8.24   4.57   3.39
        enter center lat, long of desired tile (q to quit)
        ilat,ilon,crustal type:   71 279
        topography:   0.939999998    
        layers: vp,vs,rho,bottom
        1.50   0.00   1.02   0.94
        3.81   1.94   0.92   0.94
        2.50   1.07   2.11   0.84
        0.00   0.00   0.00   0.84
        0.00   0.00   0.00   0.84
        6.10   3.55   2.74 -14.96
        6.30   3.65   2.78 -28.96
        7.00   3.99   2.95 -35.06
        pn,sn,rho-mantle:    8.24   4.57   3.39
    + station informations
        EW02 19.79550 94.04360 20.0 MM
        EW03 19.42590 93.52230 20.0 MM
        EW04 20.34280 94.51760 45.0 MM
        EW05 20.33260 95.02800 145.0 MM
----------------------------------------------------------------------------------
input parameters: (input.params)
    +   it simply filename of 
        * coordinates data:
        * output of crust1.0 program
        NOTE: filename in [input] directory
----------------------------------------------------------------------------------
How to run:
    + type 2 command
        make clean
        make
    + files generation:
        > output/models_layercake: all 1D model read from crust1.0
        > output/models_gradient: all intepolated model from output/models_layercake
        > output/figures: plots that corresponds to 1D models of 2 above output directory

        >> MOD3D : final output 3D model can not use to relocation (if no warning plot out)
    + checkpoint files generation:
        > pnsn_map.dat : this one for mantle VP-VS. can use to plot by pygmt
        > 00_query_coordinantes.dat : querry all coordinantes from list (look similar to MOD3D header)
----------------------------------------------------------------------------------
Anything else:
    If any other issue, kindly email to: havinhlong1988@gmail.com
