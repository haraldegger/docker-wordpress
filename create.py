import os
import gzip

def Dockerize(repository, project):
    #preparing paths to output (tar and tgz) and input (srv)
    tarPath = os.path.abspath(os.getcwd() + "/" + project + ".tar")
    tgzPath = os.path.abspath(os.getcwd() + "/" + project + ".tar.gz")
    srvPath = os.path.abspath(os.getcwd() + "/srv/")

    #removing data from previous run (if any)
    print("=== Cleaning up previously failed runs... ===")
    os.system("docker image rm -f " + repository + "/" + project)
    os.system("docker rm -f " + project + "_container")
    if os.path.exists(tarPath):
      os.remove(tarPath)
    if os.path.exists(tgzPath):
      os.remove(tgzPath)

    #on first start we simply copy the whole content of our local srv folder to the docker /srv folder
    print("=== Starting docker and copying files... ===")
    os.system("docker run --name " + project + "_container -v \"" + srvPath + "\":/tmp/srv/ debian:latest cp -R /tmp/srv /")
    os.system("docker commit " + project + "_container " + repository + "/" + project)
    #on second run we start the container with the /srv/bin/start.sh script, which will install all packages 
    print("=== Starting docker and install it... ===")
    os.system("docker rm -f " + project + "_container")
    os.system("docker run --name " + project + "_container " + repository + "/" + project + " /srv/bin/start.sh")
    os.system("docker commit " + project + "_container " + repository + "/" + project)
    #on third run the docker container will be configured (depending on ENV Variables)
    #we will not do this now, this will be done when you first setup the container so you get an individual container and not the same as everyone else
    #on fourth, fifth, sixth, ... run the docker container will execute the software

    # exporting the docker container
    print("=== Exporting docker... ===")
    os.system("docker save --output \"" + tarPath + "\" " + repository + "/" + project)

    #since docker exports only in tar we zip it to a tar.gz file, which is smaller and therefore more convenient to handle
    print("=== Compressing image... ===")
    tarFile = open(tarPath, 'rb')
    tgzFile = gzip.open(tgzPath, 'wb')
    tgzFile.writelines(tarFile)
    tgzFile.close()
    tarFile.close()

    #cleaning up all temporary files and containers
    print("=== Cleaning up after us... ===")
    os.remove(tarPath)
    os.system("docker image rm -f " + repository + "/" + project)
    os.system("docker rm -f " + project + "_container")

    #here we go, priting out mininum info how to use the container
    print("=== Finished ===")
    print("Use the following commands to launch the newly create docker image")
    print("docker load --input \"" + tgzPath + "\"")
    print("docker run --name putyournamehere --restart=always -p 1000:443 -p 1001:22 -e MY_USERNAME=\"username\" -e MY_PASSWORD=\"password\" -e MY_PACKAGES=\"php8.2-sqlite3\" " + repository + "/" + project)

if __name__ == "__main__":
    Dockerize('haraldegger', 'docker-wordpress')
