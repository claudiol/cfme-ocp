# CFME Server configuration
Once you've deployed the database appliance, navigate to the database appliance's web console.
* Settings --> Configuration
## Server Configuration
For each appliance, do the following
1. Provide a **Company Name** (e.g. MyCompany)
2. Provide an **Appliance Name** (e.g. CFMEDB)
3. Set your timezone
4. Apply the **Server Roles**.  Please note these are only recommended settings.

| Role | CFMEDB | CFMEWK1 | CFMEWK2 |
| ---- | ------ | ------- | ------- |
| Automation Engine | Off | On | On |
| Capacity & Utilization Coordinator | Off | On | On |
| Capacity & Utilization Data Collector | Off | On | On |
| Capacity & Utilization Data Processor | Off | On | On |
| Database Operations | On | Off | Off |
| Database Synchronization | Off | Off | Off |
| Event Monitor | Off | On | On |
| Git Repositories Owner | Off | Off | Off |
| Notifier | On | Off | Off |
| Provider Inventory | Off | On | On |
| Provider Operations | Off | On | On |
| RHN Mirror | Off | On | On |
| Reporting | Off | On | On |
| Secheduler | Off | On | On |
| SmartProxy | Off | On | On |
| SmartState Analysis | Off | On | On |
| User Interface | On | Off | Off |
| Web Services | On | Off | Off |
| Websocket | On | Off | Off |

5. Configure e-mail (if desired, but I recommend it).  I used Gmail in this example.
  * Host: smtp.gmail.com
  * Port: 587
  * Domain: gmail.com
  * Start TLS Automatically: On
  * SSL Verify Mode: None
  * Authentication: login
  * User Name: *Your Gmail login with the @gmail.com*
  * Password: Your gmail application Password
  * From E-mail Address: This could be anything
