#!/bin/sh
for i in firefox mozilla konqueror ; do
        if test -x "/usr/bin/$i"; then
                /usr/bin/$i "https://myprofile.oracle.com/EndUser/faces/profile/createUser.jspx?nextURL=http://forums.oracle.com"
                exit $?
        fi
done
