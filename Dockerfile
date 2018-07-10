FROM golang:alpine as build

ENV TERRAFORM_VERSION=0.11.7
ENV TF_DEV=true
ENV TF_RELEASE=true

WORKDIR $GOPATH/src/github.com/hashicorp/terraform
RUN apk --update add git bash && \
    git clone https://github.com/hashicorp/terraform.git ./ && \
    git checkout v${TERRAFORM_VERSION} && \
    /bin/bash scripts/build.sh && \
    rm -rf $GOPATH/src/github.com/hashicorp/terraform



FROM golang:alpine

COPY --from=build /go/bin/terraform /bin/terraform
WORKDIR /repo
RUN apk add --update git bash openssh python py-pip curl file && \
    pip install --upgrade awscli && \
    apk --no-cache add ca-certificates && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-git-crypt/master/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-git-crypt/releases/download/0.6.0-r0/git-crypt-0.6.0-r0.apk && \
    apk add git-crypt-0.6.0-r0.apk && \
    rm -f git-crypt-0.6.0-r0.apk && \
    rm -rf /var/cache/*
CMD ["/bin/bash"]
