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
   
   * First of all, login to your Buildpiper server.
   
   * Click on the `Step Catalogs` option.

   <img src=./snapshots/1.png>

   * Then click on the `New Step` option.

   <img src=./snapshots/2.png>

   * Now entry the `Step Name` and `Step Code`.
   
   * Select the `Step Category`.

   <img src=./snapshots/3.png>

   * Select the `Step Type`.

   <img src=./snapshots/4.png>

   * Add the `Add Mount Details` and select the `Mount Name` from the drop down.

   <img src=./snapshots/5.png>

   * Now select the `Env. build data path` and add the `Environment Variable`.

   <img src=./snapshots/6.png>

   * After providing all the requried fields now click on the `Save` option

   * And save the `Step`.
   
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
