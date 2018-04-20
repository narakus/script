from time import sleep,strftime
from concurrent import futures

def display(*args):
	print(strftime('[%H:%M:%S]'), end=' ')
	print(*args)

def loiter(n):
	msg = '{}loiter({}):doing nothing for {}s...'
	display(msg.format('\t'*n,n,n))
	sleep(n)
	msg = '{}loiter({}):done'
	display(msg.format('\t'*n,n))
	return n * 10

def main():
	display('Script starting')
	exector = futures.ThreadPoolExecutor(max_workers=3)
	results = exector.map(loiter,range(5))
	display('results:',results)
	display('Waiting for individual results:')
	for i,result in enumerate(results):
		display('result {}:{}'.format(i,result))

if __name__ == '__main__':
	main()