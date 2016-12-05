#/bin/bash

cd /opt/app/data/ \
&& pwd >> /opt/app/scripts/archive-data.log \
&& find ./201* -maxdepth 0 -type d -mtime +1 -exec tar cvzf {}.tar.gz {} \; >> /opt/app/scripts/archive-data.log \
&& find ./201* -maxdepth 0 -type d -mtime +1 -exec rm -rf {} \; >> /opt/app/scripts/archive-data.log \
&& find . -iname "*.tar.gz" -mtime -30 -exec mv {} /opt/archive/data/ \;

cd /opt/app/logs/ \
&& pwd >> /opt/app/scripts/archive-logs.log \
&& find ./*.log -maxdepth 0 -type f -mtime +1 -exec gzip {} \; >> /opt/app/scripts/archive-logs.log \
&& find . -iname "*.gz" -mtime -30 -exec mv {} /opt/archive/logs/ \;

cd /opt/app/execution/history/ \
&& pwd >> /opt/app/scripts/archive-execution.log \
&& find ./201* -maxdepth 0 -type d -mtime +1 -exec tar cvzf {}.tar.gz {} \; >> /opt/app/scripts/archive-execution.log \
&& find ./201* -maxdepth 0 -type d -mtime +1 -exec rm -rf {} \; >> /opt/app/scripts/archive-execution.log \
&& find . -iname "*.tar.gz" -mtime -30 -exec mv {} /opt/archive/execution/history/ \;

#Finally replicate our cold spare
nohup rsync -av --exclude-from 'rsync-exclude.list' /opt/app/ /opt/archive/ &