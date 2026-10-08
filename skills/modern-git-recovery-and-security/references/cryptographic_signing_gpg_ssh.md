# Cryptographic Commit Signing: SSH Keys & GPG Standards

In Git, authorship metadata (`user.name` and `user.email`) is completely unauthenticated. Anyone can configure their local Git client to author commits impersonating anyone else (even tech leads, CTOs, or open-source maintainers).

Cryptographic commit signing verifies provenance: it mathematically proves that a commit or release tag was authored by the holder of a specific private key, granting the **"Verified"** badge on GitHub and GitLab.

---

## 1. The Modern Shift: SSH Signing over GPG

For decades, developers endured GPG (GNU Privacy Guard) to sign commits. GPG is notoriously difficult to configure, requires complex `gpg-agent` daemons, expires unpredictably, and often breaks across operating system updates.

Starting with **Git 2.34+**, Git natively supports **signing commits with standard SSH keys** (`id_ed25519`). Since every software engineer already uses SSH keys for repository access, SSH signing eliminates all external GPG tooling.

---

## 2. Configuring Modern SSH Commit Signing (Step-by-Step)

### Step 1: Ensure Modern Git
Verify your Git version is 2.34 or higher:
```bash
git --version
```

### Step 2: Configure Git to Use SSH for Signing
```bash
git config --global gpg.format ssh
```

### Step 3: Specify Your Public SSH Key
Point Git to your public SSH key file (Ed25519 is strongly recommended over RSA):
```bash
git config --global user.signingkey ~/.ssh/id_ed25519.pub
```
*(On Windows or macOS, you can also pass the literal public key string, e.g., `ssh-ed25519 AAAAC3Nza...`)*

### Step 4: Enable Automatic Signing for Commits & Tags
```bash
# Automatically sign every commit
git config --global commit.gpgsign true

# Automatically sign every annotated release tag
git config --global tag.gpgSign true
```

### Step 5: Register Your Signing Key on GitHub / GitLab
1. Copy your public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
2. Navigate to **GitHub Settings -> SSH and GPG keys**.
3. Click **New SSH Key**.
4. In the **Key type** dropdown, select **Signing Key** (or use for both Authentication & Signing).
5. Paste your key and save.

Every subsequent commit will display the green **"Verified"** badge on GitHub!

---

## 3. Local Signature Verification (`allowed_signers`)

To verify signatures locally on your machine via `git log --show-signature`:

1. Create an `allowed_signers` file mapping email addresses to public keys:
   ```bash
   echo "developer@example.com $(cat ~/.ssh/id_ed25519.pub)" >> ~/.config/git/allowed_signers
   ```
2. Configure Git to reference this file:
   ```bash
   git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
   ```
3. Verify signatures in your terminal:
   ```bash
   git log --show-signature -n 3
   ```
   Output:
   ```text
   Good "git" signature for developer@example.com with ED25519 key SHA256:...
   commit 8a1b2c...
   ```

---

## 4. Hardware Security Tokens (FIDO2 / YubiKey)

For enterprise security compliance, generate resident FIDO2 hardware-backed SSH keys that require physical touch for every commit:

```bash
# Generate hardware-backed SSH key on YubiKey
ssh-keygen -t ed25519-sk -O resident -O verify-required -f ~/.ssh/id_ed25519_sk

# Configure Git to use the hardware key
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519_sk.pub
git config --global commit.gpgsign true
```
Now, every `git commit` prompts you to physically touch your YubiKey, making private key theft virtually impossible.
