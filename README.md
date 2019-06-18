# AS200552 Outbound Mail Platform

### Scanning Host Setup Instructions

###### V1.0 17th June 2019

---

1. Install git
   * `apt-get install git`
2. Clone Repo
   * `cd /opt/`
   * `git clone https://github.com/1ClickServicesLtd/outbound-mail`
3. Run setup script
   * `chmod +x setup.sh`
   * `./setup.sh`

4. Follow on screen prompts. 
   * When prompted to install a MTA choose **2 - Postfix**
   * When prompted to Install ClamAV choose **Yes**
   * When prompted to Install missing perl modules choose **Yes**
   * When prompted to ignore Mailscanner dependencies choose **No**

5. When prompted specify **1024** as RAMDISK size
6. When prompted for default text enter **abuse@as200252.net**

7. Watch some paint dry

8. When prompted to install the Senmail::Milter interface choose **Yes** *(Default Option)*

9. Edit `/opt/mailwatch/mailscanner/conf.php` 

   * Add IP addresses to `RPC_ALLOWED_CLIENTS`
   * Ensure timezone is set correctly

10. Edit 

    * `/opt/mailwatch/upgrade.php`,  

    * `/usr/local/bin/mailwatch_postfix_relay.php` 
    * `/usr/local/bin/mailwatch_mailscanner_relay.php` 
      * To point to mailwatch install

    * `$pathToFunctions = '/opt/mailwatch/mailscanner/functions.php';`
    * `$pathToMailscannerDir = '/opt/mailwatch/mailscanner/';`

11. Ensure we have db backup
12. Run Upgrade Script
    * `php /opt/mailwatch/upgrade.php`

13. Edit

    * `/etc/apache2/sites-enabled/000-default.conf`

    * `/etc/postfix/main.cf`
      * Ensure correct hostname is set in both files

14. Correct file permissions
    * `chown -R postfix:mtagroup /var/spool/MailScanner/incoming`
    * `chown -R postfix:mtagroup /var/spool/MailScanner/ramdisk_store`
    * `chmod 777 -R /opt/mailwatch/mailscanner/temp/`

15. Add the following to `/etc/security/limits.conf`

    ```
    hard nofile 65535
    soft nofile 65535
    root hard nofile 65535 
    root soft nofile 65535
    ```

16. Switch to dkimsync user

    * `su dkimsync`

17. Add the following to crontab:

    ``` 
    0 */2 * * * service opendkim reload
    */5 * * * * /var/dkim/gen_dkim_tables > /dev/null 2>&1
    ```

18. Switch back to root and reboot host prior to testing.
    * `exit`
    * `reboot`