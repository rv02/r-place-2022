from urllib.request import Request, urlopen
import boto3
import urllib3


def lambda_handler(event, context):
    # TODO implement
    def download(url):
        urlopen(Request(url, headers={'Accept-Encoding': 'gzip'}))   #Provide URL  
        s3.meta.client.upload_fileobj(http.request('GET', url, preload_content=False), 'place-2022-data-lake', "raw/" + url[-11:])
    
    urls = ['https://placedata.reddit.com/data/canvas-history/2022_place_canvas_history-0000000000{file_no}.csv.gzip'
                .format(file_no = '0'+ str(i) if i < 10 else str(i)) for i in range(13, 16)]
    session = boto3.Session()
    s3 = session.resource('s3')
    http=urllib3.PoolManager()
    for url in urls:
        download(url)
    return {
        'statusCode': 200
    }
     


        
                
                
