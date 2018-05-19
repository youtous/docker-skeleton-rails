# docker-skeleton-rails
This is a skeleton which helps for creating a Rails application using Docker. 

## How to start ?
##### 1. Copy `.env.sample` to `.env`.

This file contains an example of environment variables. These variables are shared between _Docker_ and _Rails_ and any other soft that might use them.
Here is the minimal `.env` :
```
RAILS_ENV=development

DB_USER=root
DB_PASSWORD=admin
DB_PORT=5432
```
Be sure to modify Rails configuration in order to use the ENV variables defined in this file.

#### 2.Copy `docker-compose.override.sample.yml` to `docker-compose.override.yml`.

This file is local only. It permits us overriding the values of the `docker-compose.yml`.
It's useful when you need to specify values linked to the current computer, for instance you can specify
the user (UID:GID) which the image should use (useful for permissions).
```
# id -u
UID: 1000
# id -g
GID: 100
```
#### 3. _(optional)_ Edit `Makefile` and speficy a `STACK_NAME` value
By default the project's name is `rails`, all the containers will have this prefix. You can
edit this value with the name of your application. 

#### 4. Run `make create`
Before running this command, you can specify the gem you want to use in the `Gemfile`.

**Important** : `Gemfile.lock` must exists before starting the build, if missing create it with `touch Gemfile.lock`.

Answer "no" when asked about overwriting files.

#### 5. That's all
Rails is now installed, you start the stack using `make start`.

You should configure your database with rails env and other things which need configuration.

## How to use
The **Makefile** provides useful commands during development and deployment.

### Adding a gem
When you add a gem in `Gemfile`, you need to rebuild the application.

Use `make build` each time you add a gem.

### List of commands
You can have the list of all the commands with `make help`.

- `make help` : Display help.
- `make create` : Create the Rails application, see "**How to start ?**".
- `make stop` : Stop the application.
- `make stop` : Stop the application.
- `make start` : Start the application in production mode. The console is detached.
- `make restart` : Restart the application in development mode. _(if a pid file exists, delete it)_
- `make run` : Start the application in production mode. _(executes migration and database creation if needed)_

By default, the console is in attached mode when stack is started in development. To detach it, use `make start ARGS="-d"`. 

You can specify other arguments using `ARGS="--your-arguments"` with `make stop|run|stop|restart`.

### Execute commands in container


