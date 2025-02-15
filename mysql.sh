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

dnf install mysql-server -y &>>$logfilename
validate $? "installing mysql server"

systemctl enable mysqld &>>$logfilename
validate $? "enabling mysql server"

systemctl start mysqld &>>$logfilename
validate $? "starting mysql server"

mysql -h mysql.lokeshportfo.site -u root -pExpenseApp@1 -e 'show databases;' &>>$logfilename

if [ $? -ne 0 ];then
    echo "ERROR:: mysql root password not setup properly" &>>$logfilename
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$logfilename
    validate $? "setting root password"
else
    echo -e "mysql root password is already setup done..... $Y INSTALLED $N"
fi
