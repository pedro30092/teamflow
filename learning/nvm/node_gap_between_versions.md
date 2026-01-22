# NVM: The Gap Between Local State and Remote Reality

The difference between the local version and the available Node.js version is based on how **NVM (Node Version Manager)** separates environment management from package retrieval:

*   **Local Indexing vs. Remote Fetching:** `nvm use` is a local operation. It searches the `~/.nvm/versions/node/` directory for the highest existing binary. It does not perform a network handshake to verify if that version is still the current LTS.
*   **Static Alias Mapping:** When an LTS version is installed, NVM creates a local pointer. If Node v22 was installed in 2025, the local `--lts` alias remains mapped to v22. When **Node v24** becomes the new LTS (as of January 2026), NVM will not recognize it until the remote registry is explicitly queried.
*   **Version Drift:** Relying solely on `nvm use --lts` creates "Version Drift." As of **January 13, 2026**, critical security patches (e.g., **v24.13.0**) were released. Without a fresh install, a stable but unpatched binary is used.

**The Fix:** To synchronize the local state with the global release schedule, run:
```bash
nvm install --lts && nvm alias default 'lts/*'