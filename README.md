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

Connect to one of the nodes using your RabbitMQ client of choice, IP addresses are: 192.168.60.2, 192.168.60.3, 192.168.60.4. Or change the IPs in accordance with your required setup.

## License

Copyright (C) 2012-2013 Alex Petrov

Cookbooks copyrights belong to their corresponding owners.

Licensed under the [Apache Public License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
