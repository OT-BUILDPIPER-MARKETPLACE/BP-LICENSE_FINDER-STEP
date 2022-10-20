# BP-LICENSE_FINDER-STEP

## Overview
This [BP](https://www.buildpiper.io/) step leverages [License Finder](https://github.com/pivotal/LicenseFinder)
```
LicenseFinder works with your package managers to find dependencies, detect the licenses of the packages in them, compare those licenses against a user-defined list of permitted licenses, and give you an actionable exception report.
```

## Setup
* Clone the code available at [BP-LICENSE_FINDER-STEP](https://github.com/OT-BUILDPIPER-MARKETPLACE/BP-LICENSE_FINDER-STEP)
* Build the docker image
```
git submodule init
git submodule update
docker build -t ot/license_finder:0.1 .
```
* Do local testing
```
docker run -it -v $PWD:/src -e WORKSPACE=/ -e CODEBASE_DIR=src ot/license_finder
```
* Register License Finder Step in BP
* Update your job template to leverage the BP step

## Additional Info
* License Finder Step comes with a global list of approvate licences available at [Whitelisted Licenses](./default_dependency_decisions.yml)
  * MIT
  * Apache 2.0
  * The GNU General Public License, Version 2
  * LGPL
  * GNU LESSER GENERAL PUBLIC LICENSE
  * Common Public License Version 1.0
  * CDDL + GPLv2 with classpath exception
  * GNU Lesser General Public License, version 2.1
  * Public Domain