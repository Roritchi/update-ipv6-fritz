cargo build -r --target x86_64-unknown-linux-musl
rm -rf output
mkdir -p output

cp example.env.sh get-prefix.sh update-ipv6.sh post-hook.sh target/x86_64-unknown-linux-musl/release/calc-ipv6 output/
