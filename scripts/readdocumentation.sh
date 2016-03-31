#!/bin/sh
for i in firefox mozilla konqueror ; do
        if test -x "/usr/bin/$i"; then
                /usr/bin/$i "http://www.oracle.com/pls/topic/lookup?ctx=xe112&id=homepage"
                exit $?
        fi
done
