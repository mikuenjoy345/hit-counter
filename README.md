# Jake's hit counter.
Wow!

## Dependencies
These programs have a couple perl dependencies;
```
Mojolicious
IP::Socket::UNIX
```
Acquire them somehow.


Non-Perl Dependencies:
```
ImageMagick (specifically montage)
```
Acquire it somehow.

(I shell out to montage because that is easiest for me.  Image manipulation within perl...  Gonna pass on that one, sorry.)

## Start
First, verify the environment variables make sense to you then start the program like so:
``` shell
$ vim ./start.bash
$ # everything looks good!
$ ./start.bash
```

## Tips and tricks
I recommend turning 'tmp/' or whatever directory is being served into a temporary file-system, `sudo mount -o size=1M -t tmpfs none ./tmp`.  This way write-cycles on the SSD/HDD are not used up.

