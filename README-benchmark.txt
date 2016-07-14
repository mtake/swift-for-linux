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
# execute the following once to collect kernel module samples
#
sudo sh -c "echo 0 > /proc/sys/kernel/kptr_restrict"

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


#
# additional steps to draw nice chart with excel
#
cd ..
./build-processor.sh
./run-processor.sh
# open benchmark-results.xlsx with excel.
# then import output.csv as a new sheet.
# copy and paste the imported data to the existing 'output.csv' sheet.
# goto the DataByMain sheet and sort the data again, then you will see the updated chart in the ChartByMain sheet.
# goto the DataByARC sheet and sort the data again, then you will see the updated chart in the ChartByARC sheet.
