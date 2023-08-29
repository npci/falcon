FROM hyperledger/fabric-tools:2.4
RUN apk add openssl curl curl-dev gcompat libc6-compat
RUN wget https://github.com/hyperledger/fabric-ca/releases/download/v1.5.1/hyperledger-fabric-ca-linux-amd64-1.5.1.tar.gz
RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.23.10/bin/linux/amd64/kubectl \
     && tar -xvzf hyperledger-fabric-ca-linux-amd64-1.5.1.tar.gz \
     && mv bin/fabric-ca-client /usr/local/bin/fabric-ca-client \
     && mv kubectl /usr/local/bin/ \
     && chmod 755 /usr/local/bin/fabric-ca-client \
     && chmod 755 /usr/local/bin/kubectl \
     && ln -s /lib/libc.so.6 /usr/lib/libresolv.so.2