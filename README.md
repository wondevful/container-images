# Wondevful: Container Images


Images configured for development use ready to run with simple dev defaults.

**Not secure to run in production or exposed environments.**

**Use at your own risk**

All images published to Docker Hub at **https://hub.docker.com/repository/docker/giflw/wondevful/general**.


## Available images

### mssql

MS SQL Server, exposed at port **1433**, with user **sa** and password **P4ssW0rd!** set to **Developer** mode.

### activemq-(classic|artemis)

ActiveMQ exposed at port **8161** (console) and **61616** or AMPQ, with user **activemq** and password **activemq**. Other ports can be found on respective container files.