FROM aflplusplus/aflplusplus

# Install additional build dependencies.
RUN apt update && apt install -y \
    git \
    build-essential \
    clang \
    meson \
    ninja-build

# Set environment variables for ASAN instrumentation.
# Adding -D_GNU_SOURCE enables GNU-specific definitions (like SCM_CREDENTIALS) in system headers.
ENV AFL_USE_ASAN=1
ENV CFLAGS="-D_GNU_SOURCE -O1 -g -fsanitize=address"
ENV CXXFLAGS="-D_GNU_SOURCE -O1 -g -fsanitize=address"
ENV CC="afl-clang-fast"
ENV CXX="afl-clang-fast++"

# Clone and build open‑iSNS.
WORKDIR /open-isns
RUN git clone https://github.com/open-iscsi/open-isns.git . && \
    rm -rf builddir && mkdir builddir && \
    meson setup builddir --default-library=both -Dsecurity=disabled -Drundir=/tmp && \
    ninja -C builddir

# Set working directory for the fuzz harness.
WORKDIR /src
# Copy your fuzz harness source to the container.
COPY fuzz_simple_decode.c /src/fuzz_simple_decode.c

# Compile the fuzz harness.
# With headers in /open-isns/include (which contains libisns/...), this flag allows:
#   #include "libisns/message.h" to resolve correctly.
RUN afl-clang-fast $CFLAGS \
    -I/open-isns/include \
    fuzz_simple_decode.c \
    /open-isns/builddir/libisns.a \
    /usr/local/lib/afl/libAFLDriver.a \
    -o fuzz_simple_decode


# Create directories for AFL++ input and output.
RUN mkdir /input && mkdir /output

# Copy seed corpus from the local 'seeds' directory to the container's /input.
COPY seeds /input

# Launch AFL++ to start fuzzing.
# CMD ["afl-fuzz", "-i", "/input", "-o", "/output", "--", "./fuzz_simple_decode", "@@"]
CMD ["/bin/bash"]


