Camaleon CMS Docker Image
==============================

 This image is for developing with [Camaleon CMS](http://camaleon.tuzitio.com/)

REQUIREMENTS
--------------------
- `docker`
- `docker-compose`
- [docker-sync](http://docker-sync.io/)


USAGE
--------------------

### General

Use for basic templates and plugins.

```
$ docker-compose up
```

And access to `http://${DockerHost-IP}`

See. [official document](http://camaleon.tuzitio.com/documentation/category/40757-developer-docs/installation-1.html)

### Development

Developing custom templates and plugins.

```
$ docker-sync-stack start
```

And add directory of `./camaleon-cms/` to IDE project

* Install dependent tools (macOS)
```
$ sudo gem install docker-sync
$ brew install fswatch
$ brew install unison
```

* Create custom templates  
```
$ docker-compose run rails rails g camaleon_cms:theme my_theme
```
See. [official document](http://camaleon.tuzitio.com/documentation/category/40758-modules/themes-2.html)
