USE master
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = temp8, FILENAME = 'D:\MSSQL\DATA\tempdb_mssql8.ndf')
GO