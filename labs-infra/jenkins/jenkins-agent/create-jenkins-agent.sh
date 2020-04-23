#!/bin/bash

oc new-build --strategy=docker -D $'FROM quay.io/openshift/origin-jenkins-agent-maven:4.1.0\n
   USER root\n
   RUN curl https://copr.fedorainfracloud.org/coprs/alsadi/dumb-init/repo/epel-7/alsadi-dumb-init-epel-7.repo -o /etc/yum.repos.d/alsadi-dumb-init-epel-7.repo && \ \n
   curl https://raw.githubusercontent.com/cloudrouter/centos-repo/master/CentOS-Base.repo -o /etc/yum.repos.d/CentOS-Base.repo && \ \n
   curl http://mirror.centos.org/centos-7/7/os/x86_64/RPM-GPG-KEY-CentOS-7 -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \ \n
   DISABLES="--disablerepo=rhel-server-extras --disablerepo=rhel-server --disablerepo=rhel-fast-datapath --disablerepo=rhel-server-optional --disablerepo=rhel-server-ose --disablerepo=rhel-server-rhscl" && \ \n
   yum $DISABLES -y --setopt=tsflags=nodocs install skopeo && yum clean all\n
   USER 1001' --name=jenkins-agent




## Config in Jenkins:
#In Jenkins select Manage Jenkins, dismiss all warnings then click on Configure System. Scroll down to the Cloud section. Click Add Pod Template and select Kubernetes Pod Template to add another pod template to Jenkins.
#Make sure you get the following settings right:
#
#Labels: This is the name that you use in your pipeline to specify this image. Suggestion: maven-appdev.
#Docker-Image: The fully qualified name of your Docker image. Use the OpenShift internal service name (and port).
#Memory: Use 2Gi for the container memory request and limit.
#CPU: Use 1 for the cpu request and 2 for the cpu limit.
#Service Account: The service account for the pod to use.

#From the Jenkins home screen, select Manage Jenkins → Configure System.
#Select Cloud → Kubernetes → Add Pod Template → Kubernetes Pod Template:
#Name: maven-appdev
#Namespace: <empty>
#Labels: maven-appdev
#Usage: Use this node as much as possible
#The name of the pod template to inherit from: <empty>
#Containers: Add Container / Container Template
#Name: jnlp
#Docker image:
#OCP 4: image-registry.openshift-image-registry.svc:5000/GUID-jenkins/jenkins-agent-appdev
#Always pull image: <Unchecked>
#Working directory: /tmp
#Command to run: <empty>
#Arguments to pass to the command: ${computer.jnlpmac} ${computer.name}
#Allocate pseudo-TTY: <Unchecked>

#Click Advanced… to open the advanced container template settings.
#Limit Memory: 2Gi

#Click Advanced… at the very bottom of the pod template definition (just above Delete Template).
#Service Account: jenkins

#Click Save at the bottom of the screen.




## A pipeline to check it:

#Create a new Jenkins job Test Agent of type Pipeline and use this test pipeline:

#Make sure the label you request matches the label you gave your agent definition.

#node('maven-appdev') {
#  stage('Test skopeo') {
#    sh("skopeo --version")
#    sh("oc whoami")
#  }
#}
