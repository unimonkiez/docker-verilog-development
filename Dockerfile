FROM ubuntu:18.04

MAINTAINER Yuval Saraf "Yuval Saraf"
ENV REFRESHED_AT 15-03-2022

# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    HOME=/root \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    SRC=/root \
    NO_VNC_HOME=/root/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1920x1080 \
    VNC_PW=oved \
    VNC_VIEW_ONLY=false

RUN echo "root:${VNC_PW}" | chpasswd
  
WORKDIR $HOME

### Add all install scripts for further steps
ADD ./src/ $SRC/
RUN find $SRC/scripts -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN $SRC/scripts/install-tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $SRC/scripts/install-tigervnc.sh
RUN $SRC/scripts/install-no-vnc.sh

### Install openssh-server
RUN $SRC/scripts/install-openssh-server.sh

### Install firefox and chrome browser
RUN $SRC/scripts/install-firefox.sh
RUN $SRC/scripts/install-chrome.sh

### Install xfce UI
RUN $SRC/scripts/install-xfce-ui.sh

### configure startup
RUN $SRC/scripts/install-libnss-wrapper.sh
RUN mkdir $STARTUPDIR
RUN $SRC/scripts/set-user-permission.sh $HOME $SRC $STARTUPDIR

### Install RDP
RUN $SRC/scripts/install-rdp.sh

### Install zsh and tools
RUN apt -y install zsh
RUN mkdir $HOME/git-tools
RUN git clone https://github.com/sindresorhus/pure.git $HOME/git-tools/pure
RUN git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/git-tools/zsh-autosuggestions
RUN sed -i 's/required/sufficient/' /etc/pam.d/chsh
RUN chsh -s `which zsh`

EXPOSE 22 3389 $VNC_PORT $NO_VNC_PORT

ENTRYPOINT $SRC/scripts/entrypoint.sh


