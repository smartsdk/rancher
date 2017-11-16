# Introduction

This section will explain how to enable Access Control on Rancher using Fiware
Lab as the provider, and how to authenticate with it.

## Enabling Access Control through the UI

Enabling Access Control with the new Fiware auth provider goes the same way as
activating Github. Once the Rancher server instance is up, under the admin tab
one can find Access Control, choose Fiware as the provider, and fill in client
ID and Secret Key, as well as the redirect URI. This last field should
correspond to the callback URI entered in Rancher, which in turn should take
the form:

```url
http://RANCHER_HOST:8080/admin/access/fiware?isTest=1
```

## Enabling Access Control through the API

To activate Access Control from the API rather than the UI we can send a
configuration to the API endpoint <http://rancher-host:8080/v1-auth/config>. The
configuration takes the form of a JSON, for example:

```text
{
 "type":"config",
 "provider":"fiwareconfig",
 "enabled":true,
 "accessMode":"unrestricted",
 "allowedIdentities":[],
 "fiwareconfig": {...}
}
```

Fiwareconfig is a JSON object that matches the configuration defined in the
Auth Service, for instance:

```text
{
"clientId": “CLIENT_ID”,
"clientSecret": "CLIENT_SECRET”,
"redirecturi": "http://localhost:8080/"
}
```

Note that enabling Access Control via the API doesn’t automatically set admins,
as only the first user to access Rancher before Access Control is enabled
automatically becomes the admin. The easiest solution would be to create API
keys to access the API as that initial (anonymous) admin user, activate Access
Control, and use those keys to give admin privileges to other selected users
accessing Rancher afterwards.
