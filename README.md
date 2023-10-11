# SHOP4CF SISTERS

This repository contains deployment files needed for deployment of SISTERS components for SHOP4CF project.

## Prerequisites
* Docker
* Kubernetes
* Helm
* PostgreSQL * 
* 4 preconfigured domains for application (HTTPS is needed) *:
    * appname.domain.com (SISTERS client application - should replace ``<client_url>`` variable in yml files)
    * terminal.appname.domain.com (operators terminal client application - should replace ``<terminal_url>`` variable in yml files)
    * api.appname.domain.com (application api - should replace ``<api_base_url>`` variable in yml files)
    * auth.appname.domain.com (keycloak application - should replace ``<keycloak_frontend_url>`` variable in yml files)
    * tupiid.appname.domain.com (product passport explorer application - should replace ``<explore_frontend_url>`` variable in yml files)


*not required for kubernetes localhost deployment
## Deployment to Kubernetes
To run application stack you will need **kubernetes cluster**. If you do not have production grade cluster you can use one of popular one-click micro kubernetes clusters like minicube, k3s or microk8s.
Kubernetes cluster with configured access to **docker.ramp.eu** repository.

## Kubernetes running on localhost
You can use ``./initilize.sh`` script to run application on local kubernetes. Please fill ``<repo_user>`` and ``<repo_cli_password>`` to give access to RAMP docker and helm 
repository.

Database will be exposed under ``localhost:31066``. Check script output for generated database password.
* EXTRA-HOT-MAMMA client will be exposed under: http://localhost:31778
* EXTRA-HOT-MAMMA server will be exposed under: http://localhost:31777
* MCTIDS terminal will be exposed under: http://localhost:31779
* TUPIID will be exposed under: http://localhost:31780


## Database initialization
To initialize database you will need **Docker** to run initialization scripts.
Execute ``Database/initialize.sh -a HOST -p PORT -d sisters -w PGADMIN_PASSWORD`` (bash) or ``Database/initialize.ps1 -dbHost HOST -dbPort PORT -dbName sisters -pgPass 
PGADMIN_PASSWORD`` (powershell).

Default ``user/password`` is ``app_user/app_pass``.

## Helm charts
Helm charts are available from docker.ramp.eu/masta-pvt repository or in ``Helm`` directory. 

Please note the correct order of launch (check ``initialize.sh`` script for details).
  
## TUPIID Product passport
Once the TUPIID administration console is available go to Dashboards -> Import Dashboard and import file dashboard_export_20231010T121422.zip from SHOP4CF_SISTERS
/Resources/.
