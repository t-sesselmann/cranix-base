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

userlit="/home/groups/SYSADMINS/userimports/" + sys.argv[1] + "/all-students.txt"
if not os.path.isdir( "/home/groups/SYSADMINS/userimports/" + sys.argv[1] + "/passwordfiles" ):
  os.mkdir( "/home/groups/SYSADMINS/userimports/" + sys.argv[1] + "/passwordfiles", 0770 );

with open(userlit) as csvfile:
    dialect = unicodecsv.Sniffer().sniff(csvfile.read(1024))
    csvfile.seek(0)
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
            if field == "CLASS" or field == "KLASSE":
                group=row[field]
        convertHtmlToPdf(template,"/home/groups/SYSADMINS/userimports/" + sys.argv[1] + "/passwordfiles/" + group + "-" + uid + '.pdf')