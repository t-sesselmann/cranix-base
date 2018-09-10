@echo off 
set /p username="Benutzername: "

set /p password="Passwort: " 

net use Z: \\admin\%username% /persisten:no /user:thrintern\%username% %password% 
net use P: \\admin\all /persisten:no /user:thrintern\%username% %password%
net use M: \\admin\groups /persisten:no /user:thrintern\%username% %password%
net use S: \\admin\software /persisten:no /user:thrintern\%username% %password%

