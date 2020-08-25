# Useful docker images

## Development

### Adding a new image

To add new image to repository you should add dir with image name.
The dir must contain following files:

`Dockerfile` - actual docker file of an image.

`VERSION` - plain text version actual version of image which will be used as docker image tag.

`build.sh` - shell script mostly with single command starts with `docker build ...`.
Need to have ability to customize build args for some images.

*Also you could add any other files which you would like to use at build step.*

### Update an exisitng image

After making some changes in one of image dirs you should update version
in appropriate `VERSION` file for an image.

*For example for cljstyle it is [VERSION](/cljstyle/VERSION).*

### Build new version of an image

Then you could run building an image by its name to test it locally:

```shell
make build cljstyle
```

*Directory with image name should exist in repository.*


### Publish new version of an image

If you want publish or just don't want to separate building and publishing steps
you could simply run:

```shell
make publish cljstyle
```

And the version of an image you bumped will be builded and published to [Dockerhub](https://hub.docker.com/u/abogoyavlensky).


## TODO

- [ ] Add github action to automatically publish next version of changed image.
