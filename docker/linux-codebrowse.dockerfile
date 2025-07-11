FROM docker.io/bitnami/minideb:bookworm

RUN apt update && apt install -y \
        vim \
        git \
        curl \
        cscope \
        exuberant-ctags \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

COPY config.vim /root/.vimrc

RUN vim +'PlugInstall --sync' +qall

WORKDIR /workspace
CMD ["vim"]
