#!/bin/sh
for i in firefox mozilla konqueror ; do
        if test -x "/usr/bin/$i"; then
                /usr/bin/$i "http://forums.oracle.com/forums/forum.jspa?forumID=251"
                exit $?
        fi
done
