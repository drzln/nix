# application reverse proxy

The application_reverse_proxy provides an abstraction layer such that a dev host
can have multiple microservices being worked on at the same time.

the objective is to combine traefik and consul to enable use cases where we can
locally support something like project.local:3306 for mysql.

so if we have two projects foo and bar we can have a 

foo.local:3306
bar.local:3306

This permits us to have more organized development environment.
