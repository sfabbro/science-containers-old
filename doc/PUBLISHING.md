# CANFAR Container Requirements
Containers must be based on a standard Linux distribution and use `x86_64` architecture to be run on the Arbutus Cloud. If you are unsure, run `uname -a` on the container building host.

## SSSD

Containers must have an [SSSD](https://sssd.io/) client and ACL capabilities installed. On Debian/Ubuntu OS based containers, that means installing the `sssd-client` and `acl` packages.

The file `/etc/nsswitch.conf` must include the sss module in the passwd, shadow, and group entries. For example:

```
passwd:     sss files
shadow:     files sss
group:      sss files
```

