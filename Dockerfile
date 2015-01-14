FROM base/archlinux
MAINTAINER atbell

# base

# setup unprivileged user to run makepkg as
RUN groupadd sudo && \ 
    useradd a -G sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


# set environment variables
ENV HOME /root
ENV LANG en_US.UTF-8

# set locale
RUN echo en_US.UTF-8 UTF-8 > /etc/locale.gen
RUN locale-gen
RUN echo LANG="en_US.UTF-8" > /etc/locale.conf

# perform system update (must ignore package "filesystem")
RUN pacman -Syyu --ignore filesystem --noconfirm && pacman-db-upgrade

# add in pre-req from official repo
RUN pacman -S supervisor --noconfirm

# add in development tools to build packer
RUN pacman -S --needed base-devel --noconfirm

# add supervisor configuration file
ADD supervisor.conf /etc/supervisor.conf

# home
######

# create user nobody home directory
RUN mkdir -p /home/nobody

# set permissions
RUN chown -R nobody:users /home/nobody
RUN chmod -R 775 /home/nobody

# packer
########

# download packer from aur
ADD https://aur.archlinux.org/packages/pa/packer/packer.tar.gz /root/packer.tar.gz

# download packer from aur
RUN su -m a -c "cd /tmp && \
    tar -xzf packer.tar.gz && \
    cd /tmp/packer && \
    makepkg -s --noconfirm"

# install packer using pacman
RUN pacman -U /tmp/packer/packer*.tar.xz --noconfirm

# cleanup
#########

RUN pacman -Scc --noconfirm; rm -rf /root/* /tmp/* /archlinux/usr/share/locale /archlinux/usr/share/man