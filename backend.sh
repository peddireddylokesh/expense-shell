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
CHECKROOT

dnf module disable nodejs -y &>>$logfilename
validate $? "disabling nodejs module"


dnf module enable nodejs:20 -y &>>$logfilename
validate $? "enabling nodejs module"


dnf install nodejs -y &>>$logfilename
validate $? "installing nodejs"

id expense &>>$logfilename
if [ $? -ne 0 ];then
    useradd expense
    validate $? "adding expense user"
else
    echo -e "user expense already exists..... $Y skipping $N"
fi

mkdir -p /app &>>$logfilename
validate $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$logfilename
validate $? "downloading backend code"

cd /app
rm -rf /app/*
validate $? "cleaning app directory"

unzip /tmp/backend.zip &>>$logfilename
validate $? "unzipping backend code"

cd /app
npm install &>>$logfilename
validate $? "installing dependencies nodejs modules"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

#preparing mysql schema
dnf install mysql -y &>>$logfilename
validate $? "installing mysql client"

mysql -h mysql.lokeshportfo.site -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$logfilename
validate $? "setting up the transaction schema and tables" 


systemctl daemon-reload &>>$logfilename
validate $? "reloading daemon"

systemctl enable backend &>>$logfilename
validate $? "enabling backend"

systemctl restart backend &>>$logfilename
validate $? "starting backend"
