    #!/bin/bash
    userid=$(id -u)
    R="\e[31m"
    G="\e[32m"
    Y="\e[33m"
    N="\e[0m"
    Log_folder="/var/log/expense-logs"
    logfile=$(echo $0 | cut -d "." -f 1)
    timestamp=$(date '+%d-%m-%Y-%H-%M-%S')
    logfilename="$Log_folder/$logfile-$timestamp.log"
    validate(){
        if [ $1 -eq 0 ];
        then
            echo -e "$2 ...$G successfully $N"
            exit 1
        else
            echo -e "Error:: $2  .....$R failed $N"
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

    mysql_secure_installation --set-root-pass ExpenseApp@1
    validate $? "setting root password"

