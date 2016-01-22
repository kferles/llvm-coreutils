# llvm-coreutils #

#About#

This simple project automates the tedious task of compiling GNU
coreutils to LLVM Bitcode. Since this task requires several
dependencies, we use [docker](https://www.docker.com) in order to
create an image with the proper version of each dependency and finally
build the coreutils from source. All the magic happens inside the
`Dockerfile`. Currently, we only build version 8.21 of GNU coreutils
using llvm-3.6.

#Building#

Before starting all you need is to [install
docker](https://www.docker.com)(follow the "Get Started" link to get
OS-specific instructions).

After that you simply run:
* `docker build -t llvm-coreutils/llvm-coreutils .`

In order to access the bitcode files you can simply start a container
by using the following command:
* `docker run --rm -ti llvm-coreutils/llvm-coreutils`

All bitcode files are inside the `src` under the `coreutils`
directory. If you want to get the bitcode files outside the container,
please refer to docker's documentation on how to do this.
