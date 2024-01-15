      program main
!     --------------------------------------------------------------------------
!     Read the input and output of the crust1 model then translate to MOD3D of 
!     tomoppn relocation model
!     --------------------------------------------------------------------------
        parameter(max_coor=100000)
        parameter(max_n_node=1000)
        parameter(max_n_dep=100)
        parameter(max_line=max_coor*10)
        character*120 coor_file,data_file, line, dataline(max_line)
        character*24 fname
        character*17 cjk
        character*11 jk
        integer n_coor,m_line(max_coor)
        integer n_topo,nlongc,nlatc,ndep,nlongm,nlatm
        LOGICAL ex
        real lat(max_coor), long(max_coor)
        real pn(max_coor),sn(max_coor),rho(max_coor)
        real jk1,jk2,jk3
        real mdep_avg, mdep(max_coor)
        real topo_now, topo, avgtopo
        real vp_c(13),vs_c(13),rho_c(13),bottom_c(13)
        real model_mp(max_n_node,max_n_node),model_ms(max_n_node,max_n_node)
        real model_cp(max_n_node,max_n_node,max_n_dep),model_cs(max_n_node,max_n_node,max_n_dep)
        real longm(max_n_node),latm(max_n_node),longc(max_n_node),latc(max_n_node),depc(max_n_dep)
        real grdsizeh,grdsizez
        real long_now,lat_now,pn_now,sn_now
        real vp_now,vs_now,dep_now
!     --------------------------------------------------------------------------
!     Make some output directory
      call system('rm -r output')
      call system('mkdir -p output/figures')
      call system('mkdir -p output/models_layercake')
      call system('mkdir -p output/models_gradient')
!     --------------------------------------------------------------------------
        open (1,file='input.params',status='old')
          read(1,'(a)')coor_file ! file of coordinates list
          read(1,'(a)')data_file ! file with output
        close(1)
        coor_file=trim(coor_file)
        data_file=trim(data_file)
      ! write(0,'(2a)')coor_file,data_file
      ! -------------- now reading the coordinantes list -----------------------
        open(1,file="./input/"//coor_file,status="old")
        l=1
        read(1,*) !skip this line (header line)
 11     read(1,*,end=99)lat(l),long(l)
        l=l+1
        goto 11
 99     close(1)
        n_coor=l-1
        print*,"> total coordinantes input: ",n_coor
      ! ------------- now reading the moho depth and average mantle vp and vs ------
        print*,"> reading the output file of crust1"
        open(1,file="00_avg_topo_avg_moho.txt",status="unknown")
        open(2,file="./input/"//data_file, status="old")
        l=1
        nm=1
        n_topo=0
        topo=0
        do
          read(2,'(a)',iostat=ios)line
          if(ios.lt.0) exit
          dataline(l)=line
          ! count how many output of 1D model
          if (line(3:9).eq."layers:") then
            nm=nm+1 !number of model according to input coordinantes
          endif
          if (line(2:6).eq.'pn,sn') then
            ! print*,line
            read(line,'(19x,3f7.2)')pn(nm-1),sn(nm-1),rho(nm-1)
            m_line(nm-1)=l-1
          endif
          l=l+1
          if (line(2:13).eq."topography:") then
            read(line,*) jk, topo_now
            topo=topo+topo_now
            n_topo = n_topo+1
          endif
        enddo
        close(2)
        nm=nm-1
        !
        if (nm.ne.n_coor) then
          print*,"- >> The output not fit with coordinantes list. Stop!!!"
          stop
        else
          print*," >> can be process!!!"
        endif
        ! check the average moho depth
       mdep_avg=0
       do ii=1,nm
         read(dataline(m_line(ii)),'(21x,f7.2)')mdep(i)
         mdep_avg=mdep_avg+abs(mdep(i))
       enddo
        avgtopo = topo/n_topo
        mdep_avg=mdep_avg/nm
        write(1,'(a,f8.3)')"average topo (km): ",avgtopo
        write(1,'(a,f8.3)')"average moho (km): ",mdep_avg
        close(1)
        write(0,'(a10,f10.4)') "> avgtopo:", avgtopo
        write(0,'(a11,f10.4)') ">> avgmoho:", mdep_avg
        ! forming the pn-sn velocity
        open(22,file="pnsn_map.dat",status="unknown")
          do i=1,n_coor
            write(22,'(4f10.3)')long(i),lat(i),pn(i),sn(i)
          enddo
        close(22)
        ! Now forming the 1D model for crustal. and 1D intepolation
        do inc = 1,n_coor
          write(0,'(a42,2f10.4)')"Reading the model for the coordinate: X-Y",long(inc),lat(inc)
          ic_start=(13*(inc-1))+6
          ic_stop=(13*(inc-1))+13
          ! write(0,'(a2,2i5)')"> ",ic_start,ic_stop
          ! call sleep(1)
          fname="model_100.000_21.000.dat"
          write(fname(7:9),'(i3.3)')int(long(inc))
          write(fname(11:13),'(i3.3)')int((long(inc)-int(long(inc)))*1000)
          write(fname(15:16),'(f2.2)')int(lat(inc))
          write(fname(17:20),'(i3.3)')int((lat(inc)-int(lat(inc)))*1000)

          write(0,'(a)')fname
          open(1,file='./output/models_layercake/'//fname,status="unknown")
          idx=0

          write(1,"(a6,2f7.3,a)")"node: ",long(inc),lat(inc)
          write(1,'(a30)')'        vp        vs       dep'
          write(1,'(3f10.3)')0.3,0.2,-10. !fake for air velocity

          do ic_now = ic_start,ic_stop
            idx=idx+1
            read(dataline(ic_now),*)vp_c(idx),vs_c(idx),rho_c(idx),bottom_c(idx)
            if (idx.eq.3) then
              write(1,'(3f10.3)')vp_c(idx),vs_c(idx),-1.*nint(avgtopo) !fake the data for 1st layer
            elseif (idx.eq.6) then
              write(1,'(3f10.3)')vp_c(idx),vs_c(idx),0. !fake the data for 0 km
            elseif (idx.eq.7) then
            write(1,'(3f10.3)')vp_c(idx),vs_c(idx),abs(bottom_c(idx-1))
            elseif (idx.eq.8) then
              write(1,'(3f10.3)')vp_c(idx),vs_c(idx),abs(bottom_c(idx-1)) !fake the data for moho
            ! else
              
            endif
          enddo
          if (mdep_avg.lt.40) then
            write(1,'(3f10.3)')vp_c(idx),vs_c(idx),mdep_avg
            write(1,'(3f10.3)')vp_c(idx),vs_c(idx),40.
            write(1,'(3f10.3)')vp_c(idx),vs_c(idx),50.
            write(1,'(3f10.3)')vp_c(idx),vs_c(idx),60.
            write(1,'(3f10.3)')vp_c(idx),vs_c(idx),120.
            write(1,'(3f10.3)')vp_c(idx),vs_c(idx),660.
          endif
          close(1)
          ! 
          print*,"Now do the 1D linear interpolation"

          call system('python 00_linear_intepolation_1model.py ./output/models_layercake/'//fname)

        enddo
          ! From now. We can make the 3D model by reading the array

        call system("python 00.query_study_area.py ./input/"//coor_file)

        open(88,file="MOD3D",status="unknown")

        open(1,file="00_query_coordinantes.dat",status="old")
        read(1,*)grdsizeh,nlongm,nlatm
        read(1,*)grdsizeh,grdsizez,nlongc,nlatc,ndepc
        read(1,*)(longm(i),i=1,nlongm)
        read(1,*)(latm(i),i=1,nlatm)
        read(1,*)(longc(i),i=1,nlongc)
        read(1,*)(latc(i),i=1,nlatc)
        read(1,*)(depc(i),i=1,ndepc)
        close(1)

        write(88,'(f4.2,2i4)')grdsizeh,nlongm,nlatm
        write(88,'(2(f4.2,1x),3i4)')grdsizeh,grdsizez,nlongc,nlatc,ndepc
        write(88,'(1000f7.2)')(longm(i),i=1,nlongm)
        write(88,'(1000f7.2)')(latm(i),i=1,nlatm)
        write(88,'(1000f7.2)')(longc(i),i=1,nlongc)
        write(88,'(1000f7.2)')(latc(i),i=1,nlatc)
        write(88,'(100f7.2)')(depc(i),i=1,ndepc)

        ! Now reading the Mantle velocity
        open(2,file="pnsn_map.dat",status="old")
        do
          read(2,'(4f10.3)',iostat=ios)long_now,lat_now,pn_now,sn_now
          if (ios.lt.0) exit
          do i=1,nlongm
            do j=1,nlatm
              if ((longm(i)==long_now).and.(latm(j)==lat_now)) then
                model_mp(i,j)=pn_now
                model_ms(i,j)=sn_now
              endif
            enddo
          enddo
        enddo
        close(2)
        
        ! read the crustal file
        do i=1,nlongc
          do j=1,nlatc
            long_now=longc(i)
            lat_now=latc(j)
            fname="model_100.000_21.000.dat"
            write(fname(7:9),'(i3.3)')int(long_now)
            write(fname(11:13),'(i3.3)')int((long_now-int(long_now))*1000)
            write(fname(15:20),'(f6.3)')lat_now
            ! 
            inquire(file='./output/models_gradient/'//fname,exist=ex)
            if (ex) then
              continue
              ! print*,"> ",'./output/models_gradient/'//fname
              
            else
              print*,"coordinate: ",long_now,lat_now," have no data! Stop"
              print*,"> ",'./output/models_gradient/'//fname
              stop

            endif
            ! continue
            open(33,file='./output/models_gradient/'//fname,status="old")
            do 
              read(33,*,iostat=irr) vp_now,vs_now,dep_now
              if (irr.lt.0) exit
              do k=1,ndepc
                if (depc(k)==dep_now) then
                  model_cp(i,j,k)=vp_now
                  model_cs(i,j,k)=vs_now
                endif
              enddo
            enddo
            close(33)
          enddo
        enddo

        ! write mantle p velocity to files
        do j=1,nlatm
              write(88,'(1000f8.3)')(model_mp(i,j),i=1,nlongm)
        enddo
        ! write crustal Vp
        do k=1,ndepc
          do j=1,nlatc
            write(88,'(1000f8.3)')(model_cp(i,j,k),i=1,nlongc)
          enddo
        enddo
        ! write mantle Vs
        do j=1,nlatm
          write(88,'(1000f8.3)')(model_ms(i,j),i=1,nlongm)
        enddo
        ! write crustal Vs
        do k=1,ndepc
          do j=1,nlatc
            write(88,'(1000f8.3)')(model_cs(i,j,k),i=1,nlongc)
          enddo
        enddo
      close(88)

       print*,"finally done! Hehehe!"
      end program
