import re
import numpy as np
import os
from subprocess import Popen, PIPE

NUM_THREADS = 8
NUM_SWAPS = 10000
ARRAY_LIMIT = 10
ARRAY_LENGTH = 10
ARRAY = [str(ARRAY_LIMIT//2)]*ARRAY_LENGTH
CLASSES_TO_RUN = ["Null", "Synchronized","Unsynchronized", "GetNSet", "BetterSafe", "BetterSorry"]
JAVA = "java"
MAIN_FILE = "UnsafeMemory"
NUM_TO_RUN = 20

pattern_time = re.compile(' ([0-9.]+) ')
# For each of the files, run the test NUM_TO_RUN times to get good statistics
for class_to_run in CLASSES_TO_RUN:
    command = [JAVA, MAIN_FILE, class_to_run,str(NUM_THREADS),str(NUM_SWAPS),str(ARRAY_LIMIT)] + ARRAY
    
    # Calls the same command repeatedly
    # Gets the output and errors(mismatches) from execution
    str_out = ""
    list_err = []
    for i in range(NUM_TO_RUN):
        proc = Popen(command, stdout=PIPE,stderr=PIPE)
        out, err = proc.communicate()
        str_out = str_out + str(out)
        list_err.append(err) if err else None
        #proc.terminate()
        
    str_list = pattern_time.findall(str_out)
    num_list = [float(str_num) for str_num in str_list ]
    mean = np.mean(num_list)
    std = np.std(num_list)
    print(class_to_run+ ": \n" + " MEAN: " + str(mean) + " STD: " + str(std)+ " ERRORS: "+str(len(list_err)))

