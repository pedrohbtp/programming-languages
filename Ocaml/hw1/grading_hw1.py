# Title: A grading script for CS131
# Date: Jan 12, 2016
# Author: Seunghyun Yoo
# Homepage: http://relue2718.com

import os
from subprocess import Popen, PIPE, TimeoutExpired
import re
import random

OCAML_PATH = "/home/ubuntu/.opam/4.02.3/bin/ocaml"
RAND_STR = "a6b9b17503dcd9b5b8e8ad16da46c432"
GRADING_MODE = "verbose"
test_list = ["subset", "equal_sets", "set_union", "set_intersection", "set_diff",
             "computed_fixed_point", "computed_periodic_point",
             "awksub", "giant"]
expected = [3, 2, 3, 3, 4, 4, 2, 4, 3]

def get_list_of_directories():
    return [ d for d in os.listdir(".") if os.path.isdir(d) ]

def main():
    pattern = re.compile(r'val (.*)[\n ]*:[\n ]*bool[ \n]*=[ \n]*true')

    students = get_list_of_directories()
    students.remove("test")
    random.shuffle(students)

    for current_student in students:
        test_result = []
        report_filesize = 0
        report_filepath = os.path.join(current_student, "hw1.txt")
        if os.path.isfile(report_filepath):
            report_filesize = os.path.getsize(report_filepath)

        for test_name in test_list:
            try:
                current_dir = os.getcwd()
                os.chdir(current_student)
                p = Popen([OCAML_PATH], stdout=PIPE, stderr=PIPE, stdin=PIPE)
                try:
                    input_data = "#use \"hw1.ml\";;\n#use \"../test/"+test_name+".ml\";;"
                    outs, errs = p.communicate(input=input_data.encode("utf-8"), timeout=10)
                    output_str = outs.decode(encoding='utf-8')
                    test_names = re.findall(pattern, output_str)
                    # Just to make sure that unrelated booleans should not be included.
                    test_passed = sum(1 for x in test_names if RAND_STR in x)
                    test_result.append(test_passed)
                except TimeoutExpired:
                    test_result.append("Timeout")
                    p.kill()
                except:
                    test_result.append("Exception")
                    p.kill()
            finally:
                os.chdir(current_dir)
        if GRADING_MODE == "verbose":
            print ("UID: ", current_student)
            print ("Report: ", report_filesize > 0)
            print ("Test Result: ", test_result)
            print ("   Expected: ", expected)
            print ("     Result: ", test_result == expected)
        else:
            print([current_student, report_filesize]+test_result)

if __name__ == "__main__":
    main()
