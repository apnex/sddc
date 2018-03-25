# download and view default config
[root@obpc sdk]# docker run apnex/cluster
{
"server": "vcenter.lab",
"username": "administrator@vsphere.local",
"password": "VMware1!",
"clusters": [
{
"name": "Compute-01",
"ClusterConfigSpec": {
"drsConfig": {
"enabled": "1",
"vmotionRate": "3"
},
"dasConfig": {
"enabled": "1",
"failoverLevel": "3",
"admissionControlEnabled": "1",
"option": [
{
"key": "das.ignoreRedundantNetWarning",
"value": "true"
}
]
}
}
}
]
}

# create local modified config.json and mount to container
[root@obpc sdk]# docker run -v $(pwd)/config.json:/config.json apnex/cluster
{
"server": "172.16.10.13",
"username": "administrator@vsphere.local",
"password": "VMware1!",
"clusters": [
{
"name": "Compute-03",
"ClusterConfigSpec": {
"drsConfig": {
"enabled": "1",
"vmotionRate": "3"
},
"dasConfig": {
"enabled": "1",
"failoverLevel": "3",
"admissionControlEnabled": "1",
"option": [
{
"key": "das.ignoreRedundantNetWarning",
"value": "true"
},
{
"key": "das.isolationaddress0",
"value": "172.16.10.11"
},
{
"key": "das.usedefaultisolationaddress",
"value": "false"
}
]
}
}
}
]
}

# view all existing clusters
[root@obpc sdk]# docker run -v $(pwd)/config.json:/config.json apnex/cluster get

# create new clusters according to config.json
[root@obpc sdk]# docker run -v $(pwd)/config.json:/config.json apnex/cluster set
