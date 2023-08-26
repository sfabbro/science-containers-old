# Desktop software containers
The modules in this directory can be run in the skaha desktop session environment.

## Desktop Container Requirements
Containers must be based on a standard Linux distribution and use `x86_64` architecture to be run on the Arbutus Cloud. If you are unsure, run `uname -a` on the container building host.

### SSSD

Containers must have an SSSD client with ACL installed. On Debian/Ubuntu based containers, that means installing the `sssd-client` and `acl` packages.

The file `/etc/nsswitch.conf` must include the sss module in the passwd, shadow, and group entries. For example:

```
passwd:     sss files
shadow:     files sss
group:      sss files
```

## Initialization and Startup
By default, the container will run an X terminal, in which case, `xterm` must be installed on the container. You can bypass it by overwriting a `/skaha/startup.sh` executable file on the container that contains the `X11` application to be executed instead of `xterm`. See the [DS9 Dockerfile](/ds9/Dockerfile) as an example.

By default, the `CMD` and `EXECUTABLE` directives in a software container Dockerfile will be ignored on startup.  By default, a desktop software container will run a `bash` shell running within an `xterm`. 
CMD and EXECUTABLE are still useful for testing containers outside of skaha.

The container will be initially started by `root` but then switched to be run as the active CADC user.

If the container needs to do any runtime initialization, that can be done in a script named `init.sh` in the `/skaha` root directory.  This script **must not block** and needs to return control to the calling process.

If `/skaha/init.sh` is provided, a sensible directive for testing the container via docker is `CMD ["/skaha/init.sh"]`
