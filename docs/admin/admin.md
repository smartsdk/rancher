# Introduction

The following section describes in detail the way access control with Fiware Lab
was added to Rancher. Unfortunately, due to the way Rancher's access control is
built, adding a new authentication provider is not straight forward, and
requires several alterations to Rancher, and involves rebuilding several
components from scratch. This guide should provide a good overview of the
entire process, to be potentially streamlined and improved in the future, as
Rancher itself is likely to change as new versions roll in.

## Adding a custom authentication provider to the Rancher Auth Service

The implementations of the authentication providers for Rancher’s Access Control
come from the [Rancher Authentication Service ](https://github.com/rancher/rancher-auth-service),
which consists of a Golang service that handles authenticating with an external
provider, such as Github with OAUTH or Shibboleth.
To add a new implementation, in our case for Fiware’s Oauth, we created a new
subfolder under [providers](https://github.com/rancher/rancher-auth-service/tree/master/providers),
which contained 3 files: *fiware_client.go*, *fiware_provider.go* and
*fiware_account.go*. These files in turn contained the implementation of our
OAUTH client to retrieve user/orgs data from Fiware, the implementation of the
provider as required by
[Rancher’s Auth Service](https://github.com/rancher/rancher-auth-service/blob/master/providers/identity_provider.go),
and the structure definition to represent a Fiware account. In addition, we
defined a model configuration for the new Fiware implementation and added it to
the [models folder](https://github.com/rancher/rancher-auth-service/tree/master/model)
in order to be able to configure access control via the Rancher API.

## Building the custom Rancher Auth Service distribution

The project can be built like any Golang project, or by just using the Makefile,
running “make build”. The resulting compiled service will appear in the bin
directory of the go project as rancher-auth-service. To make it a
rancher-auth-service distribution for Rancher the file needs to be compressed
as tar.xz (e.g : tar cvJf rancher-auth-service.tar.xz rancher-auth-service) so
that it can be included when building a custom Rancher server image.

## Extending Rancher’s UI to support the new authentication provider

Adding a new provider to Rancher’s Auth Service requires some alterations to the
UI as well, in order to enable the users to log into Rancher from the login page
of the Rancher UI. This means extending the login components of the [UI](https://github.com/rancher/ui/tree/master/app/login/index) to support the
configuration of the new authentication service (Fiware in our case, similar to
how Github's authentication is setup [here](https://github.com/rancher/ui/blob/a911dcb9888d88ff04f59e6641b507f7b711a361/app/models/githubconfig.js)),
as well as adding the graphical elements needed for supporting the new
authentication (a simple button in the case of our Fiware authentication,
similar to the Github equivalent [here](https://github.com/rancher/ui/tree/master/app/components/login-github)),
and the UI service implementation for Fiware (once again, similar to [here](https://github.com/rancher/ui/blob/master/app/services/github.js)).
In order to activate Access Control on Rancher with the new Fiware auth provider
we also extended the admin tab to include it in the Access Control tab (see [here](https://github.com/rancher/ui/tree/891286c804e0730333bd313da997fbf6012305af/app/admin-tab/auth/github)).
More extensions could be added, but it would be wise to keep the amount of
alterations to existing code in the UI to a minimum for the sake of future
maintainability in relation to Rancher UI updates.

## Building the custom Rancher UI distribution

Building the Rancher UI can be done with the build-static script in the scripts
folder, after updating the dependencies with the update-dependencies script.
There are requirements to be fulfilled first, such as installing node.js and
bowie. See the [official Rancher UI repo](https://github.com/rancher/ui) for
details on how to install them.


## Building Cattle distribution with custom Rancher Auth Service

To use the custom authentication service and UI we built, we need to build a new
Rancher Server image that includes them. In order to do this we first need to
build a Cattle distribution that includes the new Auth Service distribution.
To build the Cattle distribution we first alter the [Cattle global properties file](https://github.com/rancher/cattle/blob/master/resources/content/cattle-global.properties)
to replace the URLs pointing to the Rancher Auth Service distribution with our
custom distribution we previously built. Then, running the release script in the
scripts directory will build the cattle.jar containing the custom Cattle. Note
that building cattle requires Java 8, as well as the unlimited JCE policy for
Java (see [here](http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html)).

## Building the custom Rancher Server image

To finally build the Rancher Server image we first replace in the [Dockerfile](https://github.com/rancher/rancher/blob/master/server/Dockerfile) the URL
pointing to the standard cattle.jar with our custom Cattle distribution, as well
as the UI distribution with our custom one, and change the tag of the image to
reflect the changes we made (e.g rancher-server-fiware), to then build the image
with the build-image.sh script.
