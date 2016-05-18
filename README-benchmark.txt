#
# Building and running Swift benchmark suite on Linux
#
# Mikio Takeuchi
#

#
# prereq:
#   operf command (rather then old opcontrol command)
#   vmlinux file (for kernel symbol, optional)
#

#
# deep copy benchmark directory in order not to polute repository
#
cp -R ../swift/benchmark .
cd benchmark

#
# apply patch for linux
#
patch -p1 < ../benchmark-patch.txt

#
# build on linux
#
chmod +x *.sh
./build.sh

#
# normal run
#
./list.sh > list.txt
./run.sh

#
# profiling run with operf
#
./run-operf.sh
