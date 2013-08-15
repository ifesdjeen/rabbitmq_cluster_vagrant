# RabbitMQ cluster setup for Vagrant

In order to set up a 3-node RabbitMQ cluster for development, clone this repository and fetch submodules:

```
git submodule init
git submodule update
```

Install [vagrant](http://www.vagrantup.com/) and [virtualbox](https://www.virtualbox.org/).

Add Ubuntu Precise 64 box:

```
vagrant box add precise64 http://files.vagrantup.com/precise64.box
```

And run:

```
vagrant up
```

Connect to one of nodes from rabbitmq, ips are: 192.168.60.1, 192.168.60.2, 192.168.60.3. Or change the IPs in accordance with your required setup.

## License

Copyright (C) 2012-2013 Alex Petrov

Cookbooks copyrights belong to their corresponding owners.

Double licensed under the [Eclipse Public License](http://www.eclipse.org/legal/epl-v10.html) (the same as Clojure) or
the [Apache Public License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
