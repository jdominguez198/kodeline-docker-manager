# MultiDocker

## What is this for?

This docker compose is made to handle the need of keeping a virtual host like situation.

I want to have my sites under specific local domains coming from port 80, but also the
advantages of different docker composes on its own sandbox.

This docker contains a nginx-proxy that can handle the above situation. A more specific example:

> http://site1.kodeline/ would internally redirect to http://localhost:8100/

> http://site2.kodeline/ would internally redirect to http://localhost:9100/


## ChangeLog

### v1.0

> CLI to start/stop/reload proxy docker and add/delete/start/stop sites in it

> Ready to use with automatized setup