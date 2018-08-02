#!/bin/ash

sampleFile='speed-monitor-sample.csv'

function upload {
    echo "Uploading local results to ${BUCKET_NAME} bucket"
    file="speed-monitor-collect-$(date +"%Y%m%d%H%M" ).csv"
    date=$(date +"%a, %d %b %Y %T %z")
    content_type='application/text'
    string="PUT\n\n$content_type\n$date\nx-amz-acl:bucket-owner-read\nx-amz-storage-class:REDUCED_REDUNDANCY\n/speed-monitor/$file"
    signature=$(echo -en "${string}" | openssl sha1 -hmac "${AWS_SECRET_ACCESS_KEY}" -binary | base64)
    curl -f -v -X PUT -T "$sampleFile" \
        -H "Host: speed-monitor.s3.amazonaws.com" \
        -H "Date: $date" \
        -H "x-amz-acl: bucket-owner-read" \
        -H "x-amz-storage-class: REDUCED_REDUNDANCY" \
        -H "Content-Type: $content_type" \
        -H "Authorization: AWS ${AWS_ACCESS_ID}:$signature" \
        "https://${BUCKET_NAME}.s3.amazonaws.com/$file" && rm $sampleFile
}

if [ "$1" = "upload" ]; then	
	upload
	exit
fi

echo "Measuring speed..."
if [ ! -f $sampleFile ]; then
    echo "Server ID,Sponsor,Server Name,Timestamp,Distance,Ping,Download,Upload" > $sampleFile
fi
content=$(/usr/bin/speedtest --csv)
if [ $? -eq 0 ]; then
	echo "$content" >> $sampleFile
else
	echo "0,0,0,$(date -u +"%Y-%m-%dT%H:%M:%S.000000Z"),0,0,0,0" >> $sampleFile
fi
