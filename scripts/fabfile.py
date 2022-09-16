from fabric import task

@task
def ping(c):
	c.run("uname -s")


