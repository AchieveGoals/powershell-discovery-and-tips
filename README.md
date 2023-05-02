# powershell-discovery-and-tips

## Completed tasks from initial project

###  20210421 LJT Completed project task:  "added Locked but Enabled AD domain user related scripts"
1. 20210421 LJT Completed project task: "added Discover Locked but Enabled AD domain user discovery using Out-GridView"
2. 20210421 LJT Completed project task: "added Quick Unlock AD User Script for Locked but Enabled domain account"
###  20210421 LJT Completed project task:  "added discovery inactive accounts for 90 days or more"
###  20210421 LJT Archival code recovery:  "added compare configured OS vs running OS in VM Guest ~circa 2017"

###  20220220 LJT Added docs.hak5.com shark-jack related Powershell script (menu driven control over sharkjack from Windows)

###  20220501 LJT added Alert Logic Fortra related script to locate agents (deployment left out as that is site-specific)

###  20220502 LJT Gathering links to update SSL Certs (IIS, Plesk, Nginx, Tomcat9, Apache)
Review this site for decent discussion and examples.  --don't run Powershell scripts from web without careful review--
[Updating IIS Certs with Posh](https://lachlanbarclay.net/2022/01/updating-iis-certificates-with-powershell) {https://lachlanbarclay.net/2022/01/updating-iis-certificates-with-powershell}

## TODO: 

May Project - translate all asset detection into a document-compatible NoSQL format (suitable for MongoDB, etc.) for dynamic web reporting, mobile monitoring, etc. Started with replacing test-connection script:

```
Original Output (from Out-GridView):
True  VEEAM 10.185.1.85
New Output: 
<asset_type>VEEAM</asset_type><asset_location>Headquarters</asset_location><asset_use>BCDR</asset_use><asset_ip>10.185.1.85</asset_ip>
```
