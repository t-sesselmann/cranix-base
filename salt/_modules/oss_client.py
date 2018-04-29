import salt
import os

#Delivers the grains of the client
def get_grains():
  return __grains__

#Sets the controller ip adress
def set_controller_ip(ip):
  if __grains__['os_family'] == 'Windows':
    text_file = open('c:\Windows\ClientControl\secret', 'w')
  else:
    text_file = open('/usr/share/oss_client/','w')

  text_file.write("%s" % ip)
  text_file.close()
  return True

#Reads the controller ip adress
def get_controller_ip():
  if __grains__['os_family'] == 'Windows':
    text_file = open('c:\Windows\ClientControl\secret', 'r')
  else:
    text_file = open('/usr/share/oss_client/','r')

  controller = text_file.read()
  text_file.close()
  return controller

#Locks the client
def lockClient():
  if __grains__['os_family'] == 'Windows':
    os.system('C:\Windows\ClientControl\ClientControl.exe lockClient')
  else:
    return True

  return True

#Unlocks the client
def unLockClient():
  if __grains__['os_family'] == 'Windows':
    os.system("taskkill /IM lockClient.exe /F")
    os.system("taskkill /IM blockInput.exe /F")
  else:
    return True
  return True

#Locks the input devices
def lockInput():
  if __grains__['os_family'] == 'Windows':
    os.system('C:\Windows\ClientControl\ClientControl.exe blockInput')
  else:
    return True

  return True

#Unlocks the input devices
def unLockInput():
  if __grains__['os_family'] == 'Windows':
    os.system("taskkill /IM blockInput.exe /F")
  else:
    return True

  return True
