# i16N1850_docker

NorESM fully coupled run with N1850 compset and f19_tn14 resolution.

- Input dataset is stored and available in zenodo (??GB)

TO BE ADDED ONCE WE HAVE ALL DATASETS (ocean missing...).

## Running NorESM fully coupled N1850 f19_tn14 with docker

### NorESM source code

The [NorESM](https://noresm-docs.readthedocs.io/en/latest/) source code is not freely available so we assumed you have access to the private [Noresm-dev repository](https://github.com/metno/noresm-dev):

```
mkdir -p /opt/uio/packages
cd /opt/uio/packages
git clone -b featureCESM2.1.0-OsloDevelopment https://github.com/metno/noresm-dev.git

# Remove obsolete python 2 prints
sed -i.bak 's/print /#AF print /' noresm-dev/cime/scripts/Tools/../../scripts/lib/CIME/case/case_submit.py
```

The NorESM source code is then passed to the docker container for running norESM.

### netCDF libraries compiled with intel compilers

#### Intel Compilers

We installed Intel studio 2018a at `/home/centos/packages/intel` and compiled them with the default GNU Compilers 4.8.5.

```
tar xvf parallel_studio_xe_2018_update1_cluster_edition.tgz
cd parallel_studio_xe_2018_update1_cluster_edition
sudo ./install.sh
```

- Install it at `/home/centos/packages/intel`
- Keep from 7 to 14

#### Installation of zlib, hdf5 and netcdf with Intel compilers

**Installation path**

```
source /home/centos/packages/intel/parallel_studio_xe_2018.1.038/bin/psxevars.sh

export PREFIX=/home/centos/packages
export ZLIB_HOME=$PREFIX/zlib/1.2.11-centos7-intel2018a
export HDF5_HOME=$PREFIX/hdf5/1.10.5-centos7-intel2018a
export NETCDF_HOME=$PREFIX/netcdf/4.7.2-centos7-intel2018a
```

**zlib**

```
cd /opt/uio/src/

wget https://www.zlib.net/zlib-1.2.11.tar.gz
tar xvf zlib-1.2.11.tar.gz
cd zlib-1.2.11
CC=icc CXX=icpc F77=ifort FC=ifort ./configure --prefix=$ZLIB_HOME
make
make install
cd ..
```

**hdf5**

```
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.5/src/hdf5-1.10.5.tar.gz
tar xvf hdf5-1.10.5.tar.gz
cd hdf5-1.10.5
CC=mpiicc CXX=mpiicpc FC=mpiifort ./configure --with-zlib=$ZLIB_HOME --prefix=$HDF5_HOME --enable-fortran --enable-parallel
make -j16
make install
```


**netCDF**

Then make sure you set-up your environment before compiling netCDF:

```
export PATH=$HDF5_HOME/bin:$PATH
export LD_LIBRARY_PATH=$HDF5_HOME/lib:$LD_LIBRARY_PATH
```

And then install netCDF.

**netCDF-C**

```
wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-c-4.7.2.tar.gz
tar xvf netcdf-c-4.7.2.tar.gz
cd netcdf-c-4.7.2
CC=mpiicc CXX=mpiicpc FC=mpiifort CPPFLAGS="-I$HDF5_HOME/include -I$ZLIB_HOME/include" LDFLAGS="-L$HDF5_HOME/lib -L$ZLIB_HOME/lib" ./configure prefix=$NETCDF_HOME --enable-netcdf4 --disable-dap
make
make install
cd ..
```

**netCDF-Fortran**

```
export PATH=$NETCDF_HOME/bin:$PATH
export LD_LIBRARY_PATH=$NETCDF_HOME/lib:$LD_LIBRARY_PATH

wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.5.2.tar.gz
tar xvf netcdf-fortran-4.5.2.tar.gz
cd netcdf-fortran-4.5.2
CC=mpiicc CXX=mpiicpc FC=mpiifort CPPFLAGS="-I$NETCDF_HOME/include" LDFLAGS="-L$NETCDF_HOME/lib" ./configure --prefix=$NETCDF_HOME
make
make install
```


Finally create an initialization file you can use for setting up your environment for compiling and running norESM:

```
cat > /home/centos/packages/esm.sh << EOF
source /home/centos/packages/intel/parallel_studio_xe_2018.1.038/bin/psxevars.sh
export PATH=/home/centos/packages/netcdf/4.7.2-centos7-intel2018a/bin:$PATH
export LD_LIBRARY_PATH=/home/centos/packages/netcdf/4.7.2-centos7-intel2018a/lib:$LD_LIBRARY_PATH
EOF
```

To use  `esmf.sh`:

```
. /home/centos/packages/esm.sh
```

### NorESM docker

Make sure inputdata and norESM source code are available (it won't download them as we suppose they both are already on disk). 
- The location of the inputdata is `/opt/uio/inputdata` 
- The location of the norESM source code is `/opt/uio/packages/noresm-dev` 
- The location of the intel compiler license file is `/opt/uio/license.lic`
- Model outputs are stored in `/opt/uio/archive` along with the `case` folder (it can be interesting to check timing).

**Important**: the folder /opt/uio/archive needs to be writable by unix group `users` (see Dockerfile) otherwise you will get a permission denied when running.

```
sudo chgrp -R users /opt/uio/archive
sudo chmod -R g+w /opt/uio/archive
```

You can check it:

```
ls -lrt /opt/uio | grep archive
```

You should have:

```
drwxrwxr-x.  8 centos users        4096 Nov  9 15:21 archive
```

### Pull and run images

```
docker pull nordicesmhub/noresm:latest
docker run -i -v /opt/uio/inputdata:/home/centos/inputdata -v /opt/uio/archive:/home/centos/archive \
              -v /opt/uio/packages:/home/centos/packages  -v /opt/uio/license.lic:/home/centos/intel_license/license.lic \
              -t nordicesmhub/noresm-i16N1850:latest
```

- We are running 5 days using 16 processors. 

