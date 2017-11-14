import BeautifulSoup as bs
import urllib
import urllib2
from sys import exit

novel_url = 'http://www.zxcs8.com/sort/23/page'

def readPage(start,end):
        url_list = []
        try:
                int(start) and int(end)
                end = end + 1 
        except ValueError as err:
                print "input number %s" %err
                exit(1)
        for i in range(start,end):
                tmp_url = novel_url + '/' + str(i)
                url_list.append(tmp_url)
        return url_list

def getBookname(url):
        d = {}
        html_doc = urllib2.urlopen(url)
        html_bs = bs.BeautifulSoup(html_doc)
        for i in html_bs.findAll('dt'):
                bookname = i.a.string
                target_url = i.a.attrs[0][1]
                d[bookname] = target_url
        return d

def downloadFile(bookname):
        for k,v in bookname.iteritems():
                download_html = urllib2.urlopen(v)
                download_bs = bs.BeautifulSoup(download_html)
                download_url = download_bs.findAll('a',target=True,rel=True)[0].attrs[1][1]
                print "downloading %s" %k
                k = k + '.rar'
                urllib.urlretrieve(download_url,k)


if __name__ == '__main__':
        for i in readPage(1,10):
                downloadFile(getBookname(i))
