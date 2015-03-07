FROM dockerfile/nodejs

# fix bashrc derp
RUN sed -i'' 's/^-e//' /root/.bashrc

RUN npm install -g express

ENV NODE_PATH /usr/local/lib/node_modules

WORKDIR /data
