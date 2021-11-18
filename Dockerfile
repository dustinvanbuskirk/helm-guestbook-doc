FROM argoproj/argocd:latest

# Switch to root for the ability to perform install
USER root

RUN apt-get update; apt-get install curl -y
RUN ls /home/argocd
RUN rm -rf /usr/local/bin/kustomize

WORKDIR /usr/local/bin

RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash

WORKDIR /go/src/github.com/argoproj/argo-cd

# Switch back to non-root user
USER 999