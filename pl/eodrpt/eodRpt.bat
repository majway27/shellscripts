@echo off
ren eodrptlog.txt eodrpt_%date:~4,2%-%date:~7,2%-%date:~10,4%_%time:~0,2%%time:~3,2%.log.txt
move *.log.txt log\
echo %date% %time% %username% >> c:\opt\eod-rpt\eodrptlog.txt
perl -w eodRpt.pl >> c:\opt\eod-rpt\eodrptlog.txt 2>>&1
echo %date% %time% "Done">> c:\opt\eod-rpt\eodrptlog.txt