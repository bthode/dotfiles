These are my personal notes for bootstrapping a new macOS machine.

Prerequisites:

Copy the machines default ssh key to ~/.ssh/id_rsa

```sh
ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null || ssh-add --apple-use-keychain ~/.ssh/id_rsa 2>/dev/null || echo "No standard SSH keys found"
```

Sign into your Apple ID account.

Install XCode command line tools:

```sh
xcode-select --install
```

Install all available updates:

```sh
softwareupdate --install --all
```

Install Nix via Determinate Systems https://determinate.systems/
Make sure to decline "Install Determinate Nix?" as it isn't support for nix-darwin yet.

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Troubleshooting:

If you encounter this error, it's likely a certificate issue due to having a custom truststore:

WARN SelfTest([ShellFailed { shell: Sh, command: "\"sh\" \"-lc\" \"exec nix build --option substitute false --option post-build-hook \\'\\' --no-link --expr \\'derivation { name = \\\"self-test-sh-1757862249764\\\"; system = \\\"aarch64-darwin\\\"; builder = \\\"/bin/sh\\\"; args = [\\\"-c\\\" \\\"echo hello > \\\\$out\\\"]; }\\'\"", output: Output { status: ExitStatus(unix_wait_status(256)), stdout: "", stderr: "error:\n … while calling the 'derivationStrict' builtin\n at <nix/derivation-internal.nix>:37:12:\n 36|\n 37| strict = derivationStrict drvAttrs;\n | ^\n 38|\n\n … while evaluating derivation 'self-test-sh-1757862249764'\n whose name attribute is located at «string»:1:14\n\n error: cannot connect to socket at '/nix/var/nix/daemon-socket/socket': No such file or directory\n" } }])

# Nix Custom Truststore Setup (macOS)

If you have a custom truststore with self-signed certificates, follow these steps to configure Nix to use your trusted certificates.
https://discourse.nixos.org/t/ssl-ca-cert-error-on-macos/31171/6

---

## 1. Export All Trusted Certificates

Export all trusted certificates from the system keychains into PEM format:

```sh
# Export system certificates
security export -t certs -f pemseq -k /Library/Keychains/System.keychain -o /tmp/certs-system.pem

# Export root certificates
security export -t certs -f pemseq -k /System/Library/Keychains/SystemRootCertificates.keychain -o /tmp/certs-root.pem

# Combine both into a single bundle
cat /tmp/certs-root.pem /tmp/certs-system.pem > /tmp/ca_cert.pem
```

---

## 2. Copy Certificate Bundle to Nix Directory

Move the combined certificate bundle to `/etc/nix/`:

```sh
sudo mv /tmp/ca_cert.pem /etc/nix/
```

---

## 3. Edit Nix Daemon Launchctl Plist

Open the Nix daemon plist for editing:

```sh
sudo vi /Library/LaunchDaemons/org.nixos.nix-daemon.plist
```

Ensure the following `EnvironmentVariables` section is present **inside** the plist `<dict>`:

```xml
<key>EnvironmentVariables</key>
<dict>
  <key>NIX_SSL_CERT_FILE</key>
  <string>/etc/nix/ca_cert.pem</string>
  <key>SSL_CERT_FILE</key>
  <string>/etc/nix/ca_cert.pem</string>
  <key>REQUEST_CA_BUNDLE</key>
  <string>/etc/nix/ca_cert.pem</string>
</dict>
```

Make sure this section appears before the `<key>ProgramArguments</key>` entry.

---

## 4. Reload the Nix Daemon Service

After editing the plist, reload the Nix daemon:
Unload may fail if the service is not running.

```sh
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist
````

---

## 5. Verify Environment Variables

Check that the service contains the correct environment variables:

```sh
sudo launchctl print system/org.nixos.nix-daemon
````

Look for the `EnvironmentVariables` section in the output to confirm your changes.

---

## Notes

- This process ensures Nix and related tools use your custom CA bundle for SSL/TLS verification.
- If you update your truststore, repeat the export and reload steps.
- For troubleshooting, check the Nix daemon logs and plist syntax.

---


Clone this current repository and cd into it:

Activate the nix config, where #air is the name of the profile.

```sh
git clone https://github.com/bthode/nix-darwin.git
cd nix-darwin
sudo nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake .#HOST
```

Home-Manager Command
```sh
nix run home-manager -- switch --flake ~/dotfiles/nix#PROFILE
```

Make use of a Github deployment key to access nix-secrets repository.
