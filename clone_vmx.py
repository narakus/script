#!/usr/bin/env python 
import csv
import getpass
import ssl
import os 
import argparse
from sys import stdout,exit
from pysphere import VIServer
from itertools import islice
from Queue import Queue
from time import sleep

#set ssl setting
ssl._create_default_https_context = ssl._create_unverified_context

def get_args():
    parser = argparse.ArgumentParser(
        description='Arguments for talking to vCenter')

    parser.add_argument('-f', '--file',
                        required=False,
                        action='store',
                        help='create from csv file')
	
    parser.add_argument('-s', '--host',
                        required=True,
                        action='store',
                        help='vSpehre service to connect to')

    parser.add_argument('-u', '--user',
                        required=True,
                        action='store',
                        help='Username to use')

    parser.add_argument('-p', '--password',
                        required=False,
                        action='store',
                        help='Password to use')

    parser.add_argument('-v', '--vm-name',
                        required=False,
                        action='store',
                        help='Name of the VM you wish to make')

    parser.add_argument('--script',
                        required=False,
                        action='store',
                        help='runing script in you clone vm machine')

    parser.add_argument('--template',
                        required=False,
                        action='store',
                        help='Name of the template/VM \
                            you are cloning from')

    parser.add_argument('--datacenter-name',
                        required=False,
                        action='store',
                        default=None,
                        help='Name of the Datacenter you\
                            wish to use. If omitted, the first\
                            datacenter will be used.')

    parser.add_argument('--vm-folder',
                        required=False,
                        action='store',
                        default=None,
                        help='Name of the VMFolder you wish\
                            the VM to be dumped in. If left blank\
                            The datacenter VM folder will be used')

    parser.add_argument('--datastore-name',
                        required=False,
                        action='store',
                        default=None,
                        help='Datastore you wish the VM to end up on\
                            If left blank, VM will be put on the same \
                            datastore as the template')

    parser.add_argument('--power-on',
                        required=False,
                        action='store_true',
                        help='power on the VM after creation')

    parser.add_argument('--no-power-on',
                        required=False,
                        action='store_false',
                        help='do not power on the VM after creation')

    parser.add_argument('--phyhost',
                        required=False,
                        action='store',
                        help='MOR of the host where the virtual machine should be registered')

    parser.add_argument('--vm-ipaddr',
                        required=False,
                        action='store',
                        help='Host address of the clone host')

    parser.add_argument('--vm-hostname',
                        required=False,
                        action='store',
                        help='Host name of the clone host')

    parser.add_argument('--vm-gateway',
                        required=False,
                        action='store',
                        help='Host gateway of the clone host')

    parser.add_argument('--vm-netmask',
                        required=False,
                        action='store',
                        help='Host netmask of the clone host')

    parser.add_argument('--vm-username',
                        required=False,
                        action='store',
                        help='username of the clone host')

    parser.add_argument('--vm-passwd',
                        required=False,
                        action='store',
                        help='passwd of the clone host')

    parser.add_argument('--show',
                        required=False,
                        action='store',
                        help='show datacenter,vmxlist,datastores')

    parser.set_defaults(power_on=True)

    args = parser.parse_args()

    if not args.password:
        args.password = getpass.getpass(
            prompt='Enter vcenter password:')

    return args

def read_csv(csvfile):
	Q = Queue()
	with open(csvfile,'r') as f:
		spamreader = csv.reader(f, delimiter=',', quotechar='|')
		for row in islice(spamreader, 1, None):
			d = {'template':row[0],'folder':row[1],
				'datastore':row[2],'power_on':row[3],
				'vmxname':row[4],'ip':row[5],'gateway':row[6],
				'netmask':row[7],'hostname':row[8],
				'tmpuser':row[9],'tmppasswd':row[10],
				'datacenter':row[11],'phyhost':row[12]
				}
			Q.put(d)
	return Q

def run_script():
	if args.file:
		template_name = d.get('template')
		template_vmx = vc.get_vm_by_name(template_name,datacenter=d.get('datacenter'))
		vm_name = d.get('vmxname')
		my_datacenter = d.get('datacenter')
		my_folder = d.get('folder')
		my_datastore = d.get('datastore')
		phyhost = d.get('phyhost')
		args_list = [dst_script,'-a',d.get('ip'),'-h',d.get('hostname'),'-g',d.get('gateway'),'-n',d.get('netmask')]
		vm_username = d.get('tmpuser')
		vm_passwd = d.get('tmppasswd')
	else:
		template_name = args.template
		template_vmx = vc.get_vm_by_name(template_name,datacenter=args.datacenter_name)
		vm_name = args.vm_name
		my_datacenter = args.datacenter_name
		my_folder = args.vm_folder
		my_datastore = args.datastore_name
		phyhost = args.phyhost
		args_list = [dst_script,'-a',args.vm_ipaddr,'-h',args.vm_hostname,'-g',args.vm_gateway,'-n',args.vm_netmask]
		vm_username = args.vm_username
		vm_passwd = args.vm_passwd
	
	print "Cloning %s virtual machine from %s.." %(vm_name,template_name),
#	template_vmx.clone(vm_name,folder=my_folder,datastore=my_datastore,host=phyhost)
	template_vmx.clone(vm_name,folder=my_folder,datastore=my_datastore)
	stdout.flush()

	clone_vm = vc.get_vm_by_name(vm_name,datacenter=my_datacenter)

	while 1:
		try:
			clone_vm.login_in_guest(vm_username,vm_passwd)
			clone_vm.send_file(setup_script,dst_script)
			clone_vm.start_process('/bin/bash',args=args_list)
			print "complete!!"
			break
		except:
			if clone_vm.is_powered_off():
				clone_vm.is_powering_on()
			sleep(10)
			continue
		
if __name__ == '__main__':
	args = get_args()
	vc = VIServer()
	if args.script:
		script = args.script
		setup_script = os.path.join(os.getcwd(),script)
		dst_script = '/tmp/' + str(script)
	print "connect to {}..".format(args.host),
	stdout.flush()
	try:
		vc.connect(args.host,args.user,args.password)
		print "done"
	except:
		print "connect to {} failed".format(args.host)
		exit(1)
	
	if args.file:
		vmxq = read_csv(args.file)

		while 1:
			if vmxq.qsize() > 0:
				d = vmxq.get()
				run_script()
			else:break

	elif args.show == 'datacenters':
		for k,v in vc.get_datacenters().items():
			print k,v

	elif args.show == 'datastores':
		for k,v in vc.get_datastores().items():
			print k,v

	elif args.show == 'vmxlist':
		for item in vc.get_registered_vms():
			print item
	else:
		run_script()

	vc.disconnect()
