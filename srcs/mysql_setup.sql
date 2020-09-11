CREATE DATABASE wordpress;

update mysql.user set plugin = 'mysql_native_password' where user='root';
