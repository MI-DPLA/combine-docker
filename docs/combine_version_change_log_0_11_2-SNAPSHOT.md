## COMBINE-DOCKER v0.11.2-SNAPSHOT change log

These changes have not been tested against a Windows install.

Changes in this code are mostly targeted at improving the
installation documentation and installation scripts on Linux.
The installer has been tested on Ubuntu Server 22.04 and
Ubuntu Server 20.04.

The LIVY release changed from 0.6.0-incubating to 0.7.0-incubating.

A remote repository change required changing:

    repo.continuum.io/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh

to:

    repo.continuum.io/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh

...in the combine/Dockerfile.

Verbosity has been reduced for tar commands run by the build
scripts.  Intent is to make it easier to examine logs.

The output from "build.sh" is now being dumped to a logfile for 
post-mortem analysis.  Yes, the implementation is clunky and ugly,
but it works.

The "build.sh" output includes information that will assist in 
tracking where the process fails in the case of installation
problems.  Output from the commands invoked by "build.sh" is 
(with many exceptions) indented 4 spaces.

Internal commenting of the "build.sh" has been improved, to aid
in debugging problems.

Output to the screen during the installation via "build.sh" has
been improved for a better user experience.

The installation documentation for the Linux platform was in PDF
format.  The content has been migrated to a .md file to make it
possible to easily update details without replacing the entire
document.
