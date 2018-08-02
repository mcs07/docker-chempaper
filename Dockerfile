FROM debian:stretch
LABEL maintainer "Matt Swain <m.swain@me.com>"

RUN mkdir -p /paper

WORKDIR /paper

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates perl unzip wget \
 && rm -rf /var/lib/apt/lists/*

# Install pandoc
RUN wget -q https://github.com/jgm/pandoc/releases/download/2.2.2.1/pandoc-2.2.2.1-1-amd64.deb \
 && dpkg -i pandoc-2.2.2.1-1-amd64.deb \
 && rm -f pandoc-2.2.2.1-1-amd64.deb

## Install pandoc-crossref
RUN wget -q https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.2.1/linux-ghc84-pandoc22.tar.gz \
 && tar -xvf linux-ghc84-pandoc22.tar.gz \
 && mv pandoc-crossref /usr/local/bin/ \
 && rm -f linux-ghc84-pandoc22.tar.gz

# Install ghr for uploading results to github
RUN wget -q https://github.com/tcnksm/ghr/releases/download/v0.10.2/ghr_v0.10.2_linux_amd64.tar.gz \
 && tar -xvf ghr_v0.10.2_linux_amd64.tar.gz \
 && mv ghr_v0.10.2_linux_amd64/ghr /usr/local/bin/ \
 && rm -f ghr_v0.10.2_linux_amd64.tar.gz \
 && rm -rf ghr_v0.10.2_linux_amd64

# Install minimal texlive
COPY texlive.profile .
RUN wget -q http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
 && mkdir install-tl \
 && tar --strip-components=1 -C install-tl -xvf install-tl-unx.tar.gz \
 && rm -f install-tl-unx.tar.gz \
 && ./install-tl/install-tl --profile=texlive.profile \
 && rm -rf install-tl \
 && rm -f texlive.profile
ENV PATH="/usr/local/texlive/2017/bin/x86_64-linux:${PATH}"

# Install latex packages
RUN tlmgr install \
    achemso amsmath booktabs caption collection-fontsrecommended float geometry graphics hyperref l3kernel l3packages \
    latex-bin latexmk mhchem natbib oberdiek setspace subfig tools url xkeyval

VOLUME ["/paper"]
