# Miku's hit counter.
Wow!  This requires a full FQDN, such as 'https://counter.example.com/'.  It is quite basic.  And all hits will increase the counter number.  It's been programmed to NOT DoS your machine if the counter gets swarmed, preferring to create the counter image *after* a certain amount of time.

Can use custom assets, just make sure they're same size eg 58x40px or something.

## Dependencies
### Perl
These programs have a couple perl dependencies;
```
Mojolicious
IO::Socket::UNIX
```
Acquire them somehow.  Mojolicious is installable as
```
# apt install libmojolicious-perl
```

but for IO::Socket::UNIX that is not possible; one must install from cpan (or cpanminus which is considered better and more lightweight.)
```
% cpanm IO::Socket::UNIX
```
### Non-Perl Dependencies:
* ImageMagick (specifically montage)

Acquire it somehow.
```
# apt install imagemagick
```

(I shell out to montage because that is easiest for me.  Image manipulation within perl...  Gonna pass on that one, sorry.)

## Start
First, verify the environment variables make sense to you then start the program like so:
``` shell
$ cp ./start.bash.example ./start.bash
$ vim ./start.bash
$ # everything looks good!
$ ./start.bash
```

## Tips and tricks
I recommend turning 'tmp/' or whatever directory is being served into a temporary file-system, `sudo mount -o size=1M -t tmpfs none ./tmp`.  This way write-cycles on the SSD/HDD are not used up.

## Other info
One can run multiple instances of this program, given that `./start.bash` is renamed and every ENV variable is changed.

## How to use on websites
```
<img src="//counter.example.com" border="0">
```
