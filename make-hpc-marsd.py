#!/usr/bin/env python

import re
import sys

fixfile_reg = re.compile(r'.*fix$')

with open(sys.argv[1],"r") as f_in:
    nf = sys.argv[2]
    f = open("args.txt","w")
    f.write("params,fixfile\n")

    one_file_str = ""
    fix_file = ""
    for i in f_in:
        print("i: " + i)
        #print("one_file_str: " + one_file_str)
        #print("fix_file: " + fix_file)
        if ".fix" in i:
            i=i.strip()
            fix_file = i
            name = i.replace(".fix","")
        elif "EOF" in i:
            one_file_str += i
            print("printing fix file")
            with open(fix_file, "w") as fix_out:
                fix_out.write(one_file_str)
            fix_out.close()
            f.write("params-marsd-" + nf + ".txt," + fix_file + "\n")
            one_file_str = ""
        else:
            one_file_str += i

    fix_out.close()     
    f.close()  
    
    
