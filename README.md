# swift-for-linux

My script for building and running Swift on Intel Linux.

## Quick Start
1. Create an empty directory and cd to the directory
2. Clone this repository
```sh
$ git clone https://github.com/mtake/swift-for-linux.git
```
3. Clone Swift repository
```sh
$ git clone https://github.com/apple/swift.git
```
4. Change directory to this repository
```sh
$ cd swift-for-linux
```
5. Build Swift
```sh
$ ./update-deps.sh
$ ./build.sh-1st
$ ./build.sh-2nd
```

## Building and running Swift benchmark suite
Please refer to README-benchmark.txt.
