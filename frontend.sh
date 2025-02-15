#!/bin/bash
userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Log_folder="/var/log/expense-logs"

[ ! -d "$Log_folder" ] && mkdir -p "$Log_folder"

logfile=$(basename $0 | cut -d "." -f 1)

timestamp=$(date '+%d-%m-%Y-%H-%M-%S')

logfilename="$Log_folder/$logfile-$timestamp.log"
validate(){
    if [ $1 -eq 0 ];
    then
        echo -e "$2 ...$G successfully $N"
    else
        echo -e "Error:: $2  .....$R failed $N"
        exit 1

    fi
}
CHECKROOT(){
    if [ $userid -ne 0 ];
    then
    echo "Error:: you must have sudo access to execute this script"
    exit 1
    fi
}
echo "script started executing at $timestamp" &>>$logfilename

mkdir -p $Log_folder
echo "script started executing at $timestamp" &>>$logfilename

CHECKROOT

dnf install nginx -y &>>$logfilename
validate $? "installing nginx service"

systemctl enable nginx &>>$logfilename
validate $? "enabling ngnix service"

rm -rf /usr/share/nginx/html/* &>>$logfilename
validate $? "removing default files"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logfilename
validate $? "downloading frontend code"

cd /usr/share/nginx/html &>>$logfilename
validate $? "changing directory to html directory"

unzip /tmp/frontend.zip &>>$logfilename
validate $? "extracting frontend code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
validate $? "copying expense configuration"

systemctl restart nginx &>>$logfilename
validate $? "restarting nginx service"