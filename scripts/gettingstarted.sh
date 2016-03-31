#!/bin/sh
#
# $Header: rdbms/install/xe/dist/linux/config/scripts/gettingstarted.sh /st_rdbms_pt-112xe/2 2011/03/09 20:23:23 svaggu Exp $
#
# databasehomepage.sh
#
# Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved. 
#
#    NAME
#      databasehomepage.sh - <one-line expansion of the name>
#
#    DESCRIPTION
#      <short description of component this file declares/defines>
#
#    NOTES
#      <other useful comments, qualifications, etc.>
#
#    MODIFIED   (MM/DD/YY)
#    svaggu      02/25/11 - Creation
#
for i in firefox mozilla konqueror ; do
        if test -x "/usr/bin/$i"; then
                /usr/bin/$i http://localhost:%httpport%/apex/f?p=4950
                exit $?
        fi
done
