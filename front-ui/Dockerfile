FROM ghcr.io/cirruslabs/flutter
WORKDIR /app
ADD . ./
RUN flutter build apk --split-per-abi
