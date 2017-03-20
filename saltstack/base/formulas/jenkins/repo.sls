jenkins-apt-repo:
  pkgrepo.managed:
    - humanname: Jenkins Apt Repo
    - name: deb http://pkg.jenkins.io/debian-stable binary/
    - file: /etc/apt/sources.list.d/jenkins.list
    - key_url: http://pkg.jenkins.io/debian-stable/jenkins.io.key

