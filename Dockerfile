FROM debian:buster
LABEL maintainer "Matt Swain <m.swain@me.com>"

RUN mkdir -p /paper

WORKDIR /paper

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates perl unzip wget xz-utils \
 && rm -rf /var/lib/apt/lists/*

# Install pandoc
ARG PANDOC_VERSION=2.9.2.1
RUN wget -q https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb \
 && dpkg -i pandoc-${PANDOC_VERSION}-1-amd64.deb \
 && rm -f pandoc-${PANDOC_VERSION}-1-amd64.deb

## Install pandoc-crossref
ARG PANDOC_CROSSREF_VERSION=0.3.6.4
RUN wget -q https://github.com/lierdakil/pandoc-crossref/releases/download/v${PANDOC_CROSSREF_VERSION}/pandoc-crossref-Linux-${PANDOC_VERSION}.tar.xz \
 && tar -xvf pandoc-crossref-Linux-${PANDOC_VERSION}.tar.xz \
 && mv pandoc-crossref /usr/local/bin/ \
 && rm -f pandoc-crossref-Linux-${PANDOC_VERSION}.tar.xz

# Install ghr for uploading results to github
ARG GHR_VERSION=0.13.0
RUN wget -q https://github.com/tcnksm/ghr/releases/download/v${GHR_VERSION}/ghr_v${GHR_VERSION}_linux_amd64.tar.gz \
 && tar -xvf ghr_v${GHR_VERSION}_linux_amd64.tar.gz \
 && mv ghr_v${GHR_VERSION}_linux_amd64/ghr /usr/local/bin/ \
 && rm -f ghr_v${GHR_VERSION}_linux_amd64.tar.gz \
 && rm -rf ghr_v${GHR_VERSION}_linux_amd64

# Install minimal texlive
COPY texlive.profile .
RUN wget -q http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
 && mkdir install-tl \
 && tar --strip-components=1 -C install-tl -xvf install-tl-unx.tar.gz \
 && rm -f install-tl-unx.tar.gz \
 && ./install-tl/install-tl --profile=texlive.profile \
 && rm -rf install-tl \
 && rm -f texlive.profile
ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"

# Install latex packages
RUN tlmgr install \
    achemso amsmath booktabs caption collection-fontsrecommended epstopdf-pkg float \
    geometry graphics hyperref l3kernel l3packages latex-bin latexmk mhchem natbib \
    oberdiek setspace subfig tools url xcolor xkeyval

VOLUME ["/paper"]
