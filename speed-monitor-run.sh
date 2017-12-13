#!/bin/bash

if [ $1 = "upload" ]; then
	echo "doing the upload"
fi

sampleFile='speed-monitor-sample.csv'
if [ ! -f $sampleFile ]; then
    echo "Server ID,Sponsor,Server Name,Timestamp,Distance,Ping,Download,Upload" > $sampleFile
fi
content=$(speedtest --csv)
if [ $? -eq 0 ]; then
	echo "$content" >> $sampleFile
else
	echo "0,0,0,$(date -u +"%Y-%m-%dT%H:%M:%S.000000Z"),0,0,0,0" >> $sampleFile
fi

function upload {
    file="speed-monitor-collect-"
    file+=$(date +"%Y%m%d%H%M" )
    date=$(date +"%a, %d %b %Y %T %z")
    content_type='application/text'
    string="PUT\n\n$content_type\n$date\nx-amz-acl:bucket-owner-read\nx-amz-storage-class:REDUCED_REDUNDANCY\n/speed-monitor/$file"
    signature=$(echo -en "${string}" | openssl sha1 -hmac "${S3SECRET}" -binary | base64)
    (speedtest --csv >> $sampleFile) || echo "0,0,0,0,0,0,0,0" >> $sampleFile

    curl -v -X PUT \
        -H "Host: speed-monitor.s3.amazonaws.com" \
        -H "Date: $date" \
        -H "Content-Length: ${#content}" \
        -H "x-amz-acl: bucket-owner-read" \
        -H "x-amz-storage-class: REDUCED_REDUNDANCY" \
        -H "Content-Type: $content_type" \
        -H "Authorization: AWS ${S3KEY}:$signature" \
        --data "$content" "https://speed-monitor.s3.amazonaws.com/$file"
}
