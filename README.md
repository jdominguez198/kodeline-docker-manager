# kodeline-docker-manager

## What is this for?

This docker compose is made to handle the need of keeping a virtual-host-like situation.

I want to have my sites under specific local domains coming from port 80, but also the
advantages of different docker composes on its own sandbox.

This docker contains a nginx-proxy that can handle the above situation. A more specific example:

> http://site1.kodeline/ would internally redirect to http://localhost:8100/

> http://site2.kodeline/ would internally redirect to http://localhost:9100/

Currently, this manager uses only the docker repository [kodeline-docker-cms](https://github.com/jdominguez198/kodeline-docker-cms) to create the environment for those sites.



## Installation

To have a right use for previous scenario, you must edit your /etc/hosts file or use DNSMasq to point your desired entry domain to your localhost.

Once you have your local domain ready, clone the repository in a local path, and run the following command:

```
cp .env.example .env
```

Now, you have to edit the .env file and set up the variables on it, if needed.   
Go ahead to the next section to understand of the CLI commands usage.

## Usage

With this repository, you also have a CLI to handle the main commands to manage your local sites.  
You can use it from the root directory of this repository. They are separated in two groups.

### proxy

> bin/cli proxy:start

It starts the proxy service, using port 80 (or whatever you choose in your .env file) as an entrypoint of your local sites.

> bin/cli proxy:stop

Shutdown the service.

> bin/cli proxy:reload

Command for reload the config files, in case you did some manual changes on them.

### sites

> bin/cli sites:add site_name \[--site-dir=/absolute/path/to/site\] \[--site-subdir=subdir\] \[--assets-dir=relative/path/to/assets/\]

This command allows to add a new site into this manager. You can set up the directories where the service will look up to serve the site.

> bin/cli sites:delete site_name

It will remove the files generated to serve your site. If the site is on a subfolder on it, it will be removed too.

> bin/cli start site_name

Start the containers to serve your site

> bin/cli stop site_name

Stop the containers serving your site

## ChangeLog

### v1.0.0

> CLI to start/stop/reload proxy docker and add/delete/start/stop sites in it

> Ready to use with automatized setup