# Creating a D-Star Gateway Test Server

As part of my work in managing a D-Star gateway server, I set up a test machine
where I can try out management tools before adding them to the production
server. 

Rather than set up a real computer for this purpose, my test machine is a
*virtual computer*, meaning a machine created in software. This may seem odd,
but it is a popular way to create an isolated environment on a your work
machine where you can try out other operating systems, or just isolate your
software development work from anything else going on on your work machine. For
this project, we will use *Vargant* and *VirtualBox* to set up the test machine
on my Macbook. I have used these two tools in my computer science classes,
which I taught for over 17 years. 

I use a Macbook laptop fo rmost of my work, so I will show how i set this test
machine up using tools on that system. There are standard installers available
for other systems if you need them. Just navigate to the websites for those two
applicaitons.

## VirtualBox

*VirtualBox* is a virtual machine program that lets you create a machine that
is as colse as a rwal machine as possible, but one that is osolated from the
host machine. This new machine can be loaded witht he operating system of
choice, and you can decide on the physical components you want to use on your
new machine as well. 

Using *Homebrew* on my Mac, installing *Virtual box* is easy:

```{shell}
brew install --cask virtualbox
```

## Vagrant

*Vagrant* is a layer that sits above *VirtualBox* or other vistual machine
applications, tha makes loading an operating ysstem easy. For our purposes we
will use *Vagrant* to install the base *CentOS 7* operating system required by
D-Star (for now it reached end-of-life in 2024).

```{shell}
brew install hashicorp/tap/hashicorp-vagrant
```

## Ansible

When I first started managing a D-Star gateway machine, I ran into an
old-fashioned script with over 100 steps. It turned out that this script was
one of many I would encounter as I worked through setting up our G2 gateway
machine. Most of thise scripts were fairly simple, but tracking where the
scripts were located and how to run them was a bit of a nightmare. I have long
used a modern tool for managing remote machines, so for this test machine, I
will be using *Ansible*, a *Python* program used by many administrators to
manage thousands of machines. I use it to manage the setup of my teaching
laptop, since I reset that machine to a base Macbook after each semester, then
add in the tools I will need for the next semester. Rebuilding my laptop takes
minutes instead of the days it took before I started using *Ansible*1

I install *Ansible* as one of the first tings I do on a new computer (or a
rebuilt one):

```{shell}
brew install ansible
```

## Creating the Test Machine

To create a new test machine, we forst write a **Vagrantfile** in a test
directory:

```{shell}
mkdir dstar-test
cd dstar test
vim vagrantfile
```

Add this code to the **Vagrantfile**:

```{text}
Vagrant.configure(2) do |config|

  config.vm.box = "centos/7"
end
```

On my Macbook, I needed a plugin for *Vagrant* to access local files on my
Macbook inside the virtual machine. 

```{shell}
yum -y install epel-release
yum install dkms gcc make kernel-devel bzip2 binutils patch libgomp glibc-headers glibc-devel kernel-headers

vagrant plugin install vagrant-vbguest
```

Now, we can bring the new test machine up to life:

```{shell}
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
end
Now, working in the 8*dstar-test** directory, run this command:

```{shell}
vagrant up
```

This will take a while to complete. The first time you run this, command
*Vagrant* will download a file containing the operating system and create your
basic machine. 
