#!/usr/bin/python

from xhtml2pdf import pisa             # import python module
import sys
import unicodecsv
import os
try:
    from html import escape  # python 3.x
except ImportError:
    from cgi import escape 

def convertHtmlToPdf(sourceHtml, outputFilename):
    # open output file for writing (truncated binary)
    resultFile = open(outputFilename, "w+b")

    # convert HTML to PDF
    pisaStatus = pisa.CreatePDF(
            sourceHtml,                # the HTML to convert
            dest=resultFile)           # file handle to recieve result

    # close output file
    resultFile.close()                 # close output file

    # return True on success and False on errors
    return pisaStatus.err

import_dir= sys.argv[1] + "/"
user_list = import_dir + "all-students.txt"
students  = 1
if not os.path.exists( user_list ):
    user_list=import_dir + "all-user.txt"
    students = 0
if not os.path.exists( import_dir + "/passwordfiles" ):
  os.mkdir( import_dir + "passwordfiles", 0770 );

all_classes = []
with open(user_list) as csvfile:
    #Detect the type of the csv file
    dialect = unicodecsv.Sniffer().sniff(csvfile.read(1024))
    csvfile.seek(0)
    #Create an array of dicts from it
    unicodecsv.register_dialect('oss',dialect)
    reader = unicodecsv.DictReader(csvfile,dialect='oss')
    for row in reader:
        fobj = open("/usr/share/oss/templates/password.html","r")
        template = fobj.read().decode('utf8')
        fobj.close()
        uid=""
        group=""
        for field in reader.fieldnames:
            template = template.replace(field,escape(row[field]))
            if field == "UID" or field == "BENUTZERNAME" or field == "LOGIN":
                uid=row[field]
            if students == 1 and ( field == "CLASS" or field == "KLASSE" ):
                group=row[field]
                if group not in all_classes:
                    all_classes.append(group)
        if students == 1:
           convertHtmlToPdf(template, import_dir + "/passwordfiles/" + group + "-" + uid + '.pdf')
        else:
           convertHtmlToPdf(template, import_dir + "/passwordfiles/" + uid + '.pdf')

if students == 1:
  for group in all_classes:
    os.system("/usr/bin/pdfunite " + import_dir + "passwordfiles/" + group + "-*.pdf " + import_dir + "/passwordfiles/" + group + ".pdf")
    os.system("rm " + import_dir + "passwordfiles/" + group + "-*.pdf" )
else:
  os.system("/usr/bin/pdfunite " + import_dir + "passwordfiles/*.pdf " + import_dir + "/passwordfiles/ALL-USER.pdf")
  os.system("rm " + import_dir + "passwordfiles/!(ALL-USER.pdf)")

