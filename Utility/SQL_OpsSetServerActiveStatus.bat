rem *****************************
rem ** Takes 2 arguments: <Server Name> <Status>
rem *****************************

..\Common\osql -n -S %_OT_WEBDB_IP% -d %_OT_WEBDB% -E -Q "OpsSetServerActiveStatus '%1', %2"
