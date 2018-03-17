FROM bash:4.4
WORKDIR /app
VOLUME /app
ENTRYPOINT ["/app/test/test_setdown.sh"]
