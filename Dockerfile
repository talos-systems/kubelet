## Using the builder this way keeps us from having to install wget and adding an extra
## fat step that just does a chmod on the kubelet binary

FROM alpine:latest as builder-amd64

ARG TARGETARCH
ARG KUBELET_VER
ARG KUBELET_SHA512_AMD64
ARG KUBELET_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBELET_VER}/bin/linux/${TARGETARCH}/kubelet

RUN wget -q -O /kubelet ${KUBELET_URL} && \
    echo "${KUBELET_SHA512_AMD64}  /kubelet" | sha512sum -c && \
    chmod +x /kubelet

FROM alpine:latest as builder-arm64

ARG TARGETARCH
ARG KUBELET_VER
ARG KUBELET_SHA512_ARM64
ARG KUBELET_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBELET_VER}/bin/linux/${TARGETARCH}/kubelet

RUN wget -q -O /kubelet ${KUBELET_URL} && \
    echo "${KUBELET_SHA512_ARM64}  /kubelet" | sha512sum -c && \
    chmod +x /kubelet

ARG TARGETARCH
FROM builder-${TARGETARCH} as builder

FROM us.gcr.io/k8s-artifacts-prod/build-image/debian-iptables:v12.1.2 as container

RUN clean-install \
  bash \
  ca-certificates \
  ceph-common \
  cifs-utils \
  e2fsprogs \
  xfsprogs \
  ethtool \
  glusterfs-client \
  iproute2 \
  jq \
  nfs-common \
  socat \
  ucf \
  udev \
  util-linux

COPY --from=builder /kubelet /usr/local/bin/kubelet

ENTRYPOINT ["/usr/local/bin/kubelet"]
