<#
.PARAMETER dbHost
    Database host
.PARAMETER dbPort
    Database port
.PARAMETER dbName
    Database name
.PARAMETER pgPass
    Database postgres user password
#>

param (
    [Parameter(Mandatory=$true, HelpMessage="database host")][string]$dbHost,
    [Parameter(Mandatory=$true, HelpMessage="database port")][int]$dbPort,
    [Parameter(Mandatory=$true, HelpMessage="database name")][string]$dbName,
    [Parameter(Mandatory=$true, HelpMessage="postgres password")][string]$pgPass
)
Write-Host "Initializing database $dbName on host $dbHost"
$localPath=Get-Location
$expression="docker run --rm --network=host -v ${localPath}:/scripts -e PGPASSWORD=$pgPass postgres /bin/sh /scripts/run-sql.sh $dbName $dbHost $dbPort"
Invoke-Expression $expression
$expression="docker run --rm --network=host -v ${localPath}:/liquibase/changelog -w /liquibase/changelog liquibase/liquibase liquibase --changeLogFile=dbchangelog.xml --url=jdbc:postgresql://${dbHost}:${dbPort}/${dbName} --username postgres --password ${pgPass} --log-level=info update"
Invoke-Expression $expression
