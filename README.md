# bukkenoh_script_proto4
### Requirements?
For smooth setup, install all the necessary requirement.

:green_circle: Node version 8.15.0<br/>
:green_circle: PHP version 8.2.6<br/>
:green_circle: Composer 2.5.8 must be installed globally<br/>
:green_circle: Yarn must be installed globally<br/>

### What does it do?
:green_circle: it will clone the project and initialize (composer, env, htaccess, and yarn).<br/>
:green_circle: P.S doesn't initialize or replace the value of USER_ID and STORE_ID, so you need to change it manually.<br/>

### How does it work?
:green_circle: You just need to specify the gitRepositoryUrl inside the cfg.txt<br/>
:green_circle: then run the script.bat<br/>
:green_circle: P.S for every project you need to manually setup gitRepositoryUrl.<br/>

### Additional Info
:green_circle: saveLocation - default "C:\laragon\www", current VHost target provided by laragon.<br/>
:green_circle: Only works with bukkenoh current folder structure.<br/>

### Error?
* setup is finished but the browser can't find the url?
  + : restart laragon so that it will create a VHOST config for the newly added project.
* laravel error
  + : type in the url -> `/cmd/makecache`. Make sure the env is already modified with correct details (USER_ID and STORE_ID) and PHP Version must be 7 ~ 7.2.
* `/cmd/makecache` route doesn't exist?
  + : check if .htaccess exist in the root of the project folder.
