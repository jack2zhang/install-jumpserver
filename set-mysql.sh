create database jumpserver default charset 'utf8';
grant all on jumpserver.* to 'jumpserver'@'127.0.0.1' identified by 'jumpserver';
flush privileges;

