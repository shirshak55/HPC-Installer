# HPC Installer Slurm + Warewulf

Bash script for high performance cluster &amp;&amp; battle tested script.

## Requirements

- Fresh Installation Centos 7
- Git

## Installation Instruction

- Clone this repo

```bash
$  git@github.com:shirshak55/HPC-Installer.git
```

- After clone edit the input.localfile one by one especially ethernet adapters, number of computer nodes etc.

- And finally run `./recipe.sh` . You may need to make it executable by `chmod +x recipe.sh`.

- Turn off selinux by editing `/etc/selinux/config` to disabled


## Testing Jobs

```bash
yum  -y install openmpi3-gnu7 mpich-gnu7-ohpc lmod-defaults-gnu7-openmpi3-ohpc

# Compile MIP helloworld example
$ mpicc -03 /opt/ohpc/pub/examples/mpi/hello.c
$ gsub -I -l select=2:mpiprocs=1
$ prun ./a.out
```

## Future Plans

- Ask user for necessary info with defaults value set.

- Color, icons, loaders etc.

## Contributing

- PR if you found any error.
- Please star its not I need it but I value my work
- Post Issue if any problem with valid error message etc.
- If it is related to openhpc raise issue at openhpc issue not here :)

## Supporting Author

- If you like to support me you can happily raise issue in this repo or contact me directly `shirshak55[at]gmail[dot]com`

Thanks
Shirshak Bajgain