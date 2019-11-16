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

