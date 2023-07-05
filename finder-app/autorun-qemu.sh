#!/bin/sh
cd $(dirname $0)
echo "IAMAT"
echo `pwd`
echo "Running test script"
./finder-test.sh
rc=$?
echo "serial.log dump"
if [ -f /tmp/aesd-autograder/serial.log ]; then
    cat /tmp/aesd-autograder/serial.log
fi
echo "end serial.log dump"
if [ ${rc} -eq 0 ]; then
    echo "Completed with success!!"
else
    echo "Completed with failure, failed with rc=${rc}"
fi
echo "finder-app execution complete, dropping to terminal"
/bin/sh
