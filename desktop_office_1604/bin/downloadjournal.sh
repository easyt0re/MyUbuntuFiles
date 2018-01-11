#!/bin/bash

base=
file=
tempfile1="downlist.txt" #临时文件，用完删除
tempfile2="urls.txt" #临时文件，用完删除

if [ -f $tempfile1 ]; then
    rm $tempfile1
fi

if [ -f $tempfile2 ]; then
    rm $tempfile2
fi

usage()
{
    echo "Usage: `basename $0` -b url_base_string -f input_file [-h help]"
    exit 1
}

while getopts "b:f:h" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
         b)
            base=$OPTARG
            ;;
         f)
            file=$OPTARG
            ;;
         h)
            usage
            ;;
         ?)  #当有不认识的选项的时候arg为?
        echo "unkonw argument"
    exit 1
    ;;
    esac
done

if [ -z "$base" ]; then   #该脚本必须提供-b选项
    echo "You must specify base with -b option"
    exit
fi

if [ -z "$file" ]; then   #该脚本必须提供-f选项
    echo "You must specify file with -f option"
    exit
fi

cat $file | grep -o -e "arnumber=[0-9]*" -e '"[^\"]*"' >> "$tempfile1"

while read -r title; read -r arnumber #循环读取标题和arnumber
do 
  title=`echo $title | cut -d "\"" -f 2 | cut -d "," -f 1 | sed 's/\///' | sed 's/\://'`
  arnumber=`echo $arnumber | cut -d "=" -f 2`
  echo "$base/0$arnumber.pdf" >> "$tempfile2" #这里先生成所有下载链接，然后保存到临时文件
done < "$tempfile1"

wget -i $tempfile2 #批量下载论文

echo $?

while read -r title; read -r arnumber #重命名
do 
  title=`echo $title | cut -d "\"" -f 2 | cut -d "," -f 1 | sed 's/\///' | sed 's/\://'`
  arnumber=`echo $arnumber | cut -d "=" -f 2`
  mv "0$arnumber.pdf" "$title.pdf"
done < "$tempfile1"

if [ -f $tempfile1 ]; then
    rm $tempfile1
fi

if [ -f $tempfile2 ]; then
    rm $tempfile2
fi