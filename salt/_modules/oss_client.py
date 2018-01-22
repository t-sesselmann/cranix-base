import salt

def get_grains():
  return __grains__

def set_controller_ip(ip):
  if __grains__['os_family'] == 'Windows':
    text_file = open('c:\Windows\ClientControl\secret', 'w')
  else:
    text_file = open('/usr/share/oss_client/','w')

  text_file.write("%s" % ip)
  text_file.close()
  return True

def get_controller_ip():
  if __grains__['os_family'] == 'Windows':
    text_file = open('c:\Windows\ClientControl\secret', 'r')
  else:
    text_file = open('/usr/share/oss_client/','r')

  controller = text_file.read()
  text_file.close()
  return controller
