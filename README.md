File for collecting useful cli commands relative to the project. There's a lot more now that Docker is getting involved. 

Commands for first time setup.

Install Crystal lang with your appropriate installer. https://crystal-lang.org/install/on_debian/

Maybe missing commands but close enough.
```bash
curl -fsSL https://crystal-lang.org/install.sh | sudo bash
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get install -y sqlite3 libsqlite3-dev
git clone https://github.com/blueshirt-dev/acsl-signin-server.git
cd acsl-signin-server
shards install
crystal run SigninServer.cr
```

If you want the server to run in on it's own in a terminal that can be closed without issue
```bash
nohup crystal run SigninServer.cr&
```


Then run the weekly report once a week with cron.
Make sure the relevant, to, from, and smtp config changes are made.
```bash
cd /absolute/path/to/acsl-signin-server/;crystal run emailWeeklyReport.cr
```

As I don't currently feel like going through all the steps to make Docker rootless on linux all the Docker commands require sudo. 

The commands below build the relevant containers and then run them. Mount points are setup so the containers can share the same DB connection. 
```bash
sudo docker build -f server.dockerfile -t acsl-signin-server .
sudo docker build -f report.dockerfile -t acsl-weekly-report .

sudo docker run --detach --publish 3000:3000 --mount source=signin,target=/app/data acsl-signin-server
sudo docker run --detach --mount source=signin,target=/app/data acsl-weekly-report 
```

To create the tar for portainer
```bash
tar -cvf acsl-signin-server.tar *
```