# ledstrain-docker

## Versioning

This project uses rolling releases and CI/CD deployment.  

There are 3 branches available  

| Branch | Type | Site |
| ------ | ---- | ---- |
| [Master](https://github.com/ledstrain/ledstrain-docker/tree/master) | Latest development |
| [Staging](https://github.com/ledstrain/ledstrain-docker/tree/staging) | Used to test newer features | https://staging.ledstrain.org |
| [Production](https://github.com/ledstrain/ledstrain-docker/tree/production) | Re-uses staging images that are demonstrated to be stable | https://ledstrain.org |

To verify the forum is running a specific commit, check the commit of the staging or production branch,
 then compare the commit on the bottom-left of the forum
 \- [example](https://user-images.githubusercontent.com/4926565/117555653-e5bb6f00-b015-11eb-8986-5d59732be564.png).

## Making changes

These programs are used
* docker
* docker-compose
* just

`docker/composer.json` and `docker/compose.lock` are used to configure the forum when building the image.  
If these two files are changed, make sure to run `docker-compose build`

### Composer

[just](https://github.com/casey/just) is used as a command runner to make testing easier.  
To enter the container run `just enter`  
While in the container, install, update or remove plugins as needed. Eg `composer update`.  
Exit out of the container (`Ctrl-D`) and run `just update` to copy the `composer.json` and `composer.lock` files out.  
If `composer.json` is changed, a `git diff | grep` command is run to show any changes.  
Review the changes in git before committing.  



## Docker

`webdevops/php-nginx` docker [image base](https://github.com/webdevops/Dockerfile) is used, and then is [configured](https://dockerfile.readthedocs.io/en/latest/content/DockerImages/dockerfiles/php-nginx.html) on top of it.

When the image is built, it is meant to provide the structure but not the data for the forum and should be considered immutable.
This includes items like

* Core files
* All plugins
* Scheduled services

It does not include
* User files like avatars
* Database files

To update, add or remove any plugins, see [Composer](#composer)
