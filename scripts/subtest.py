import subprocess

class DStarServer(object):

    def __init__(self):
        self.kex = "KexAlgorithms=diffie-hellman-group1-sha1"
        self.host = "65.111.55.5"
        self.port = "5224"
        self.user = "n5ujh"


    def open(self):
        self.ssh = subprocess.Popen([
            "ssh", 
            "%s@%s" % (self.user,self.host), 
            "-tt",
            "-p", self.port, 
            "-o", self.kex],
            #shell=False,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)

    def run(self,command):
        self.ssh.stdin.write( bytes(command + '\n', 'utf-8'))

    def close(self):
        self.ssh.stdin.close()
        result = self.ssh.stdout.readlines()
        if result == []:
            error = ssh.stderr.readlines()
            print("ERROR: %s" % error)
        else:
            for line in result:
                lstr = str(line, encoding='utf-8')
                print(lstr.rstrip())

    def script(self, cmds):
        for l in cmds:
            self.run(l)

if __name__ == '__main__':
    server = DStarServer()
    server.open()
    server.script([
        "uname -s",
        "whoami",
        "sudo more /var/log/secure"
    ])
    server.close()
