#!/usr/bin/env

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

read -p "Username: " uservar
OUTPUT_FOLDER="/home/$uservar/collect"

folder_check ()
{
  if [ ! -d $OUTPUT_FOLDER ]; then
    mkdir $OUTPUT_FOLDER
  fi
}

gather_informations ()
{
  files=(passwd group crontab fstab *-release)
  for file in ${files[@]}; do
    cat /etc/$file > $OUTPUT_FOLDER/$file.txt
  done
}

package_informations ()
{
  arguments=(repolist list\ installed)
  for ((i = 0; i < ${#arguments[@]}; i++)); do
    yum ${arguments[$i]} > "$OUTPUT_FOLDER/${arguments[$i]}.txt"
  done
  pip freeze > $OUTPUT_FOLDER/pip.txt
}

process_informations ()
{
  chkconfig --list > $OUTPUT_FOLDER/chkconfig.txt
  service --status-all > $OUTPUT_FOLDER/service.txt
  ls -F /etc/init.d/ | grep '*$' > $OUTPUT_FOLDER/initd.txt
  ls /etc/rc*.d > $OUTPUT_FOLDER/rcd.txt
  ps aux > $OUTPUT_FOLDER/psaux.txt
  ps -eafw > $OUTPUT_FOLDER/pseafw.txt
  netstat -ntlp > $OUTPUT_FOLDER/netstatntlp.txt
}

config_informations ()
{ 
  ls -la /home/$uservar > $OUTPUT_FOLDER/home_$uservar.txt
  ls -la /root/ > $OUTPUT_FOLDER/root.txt
  sudo -Hiu $uservar env > $OUTPUT_FOLDER/env_$uservar.txt
  env > $OUTPUT_FOLDER/env_root.txt
  sudo -Hiu $uservar printenv > $OUTPUT_FOLDER/printenv_$uservar.txt
  printenv > $OUTPUT_FOLDER/printenv_root.txt
}

system_informations ()
{
  ip addr show > $OUTPUT_FOLDER/ipaddr.txt
  iptables -S > $OUTPUT_FOLDER/iptables_s.txt
  iptables -L > $OUTPUT_FOLDER/iptables_l.txt
  cat /proc/version > $OUTPUT_FOLDER/version.txt
}

log_informations ()
{
  ls -la /var/log > $OUTPUT_FOLDER/log_ls.txt
  cat /var/log/cron > $OUTPUT_FOLDER/cron_log.txt
  cat /var/log/messages > $OUTPUT_FOLDER/messages_log.txt
  last > $OUTPUT_FOLDER/last.txt
  lastlog > $OUTPUT_FOLDER/lastlog.txt
  dmesg > $OUTPUT_FOLDER/dmesg.txt
}

archive_informations ()
{
  chown -R $uservar:$uservar $OUTPUT_FOLDER
  if ! command -v zip &> /dev/null; then
    tar -czvf collect.tar.gz $OUTPUT_FOLDER
  else
    zip -r collect.zip $OUTPUT_FOLDER
  fi
}


folder_check
gather_informations
package_informations
process_informations
config_informations
system_informations
log_informations
archive_informations
