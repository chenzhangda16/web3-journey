#!/usr/bin/env bash
set -euo pipefail

PROJ="${1:-web3-journey}"
mkdir -p "$PROJ"
cd "$PROJ"

# --- Directories ---
mkdir -p .github/workflows \
  contracts script test audits reports \
  notes/evm notes/consensus notes/defispecs \
  tools \
  dapp/app dapp/src/lib

# --- Top-level files ---
cat > README.md << 'EOF'
# web3-journey

Learning-by-building: contracts + dapp + security tooling.
- Contracts: Solidity + tests (Foundry by default)
- Dapp: Next.js + wagmi + viem
- Tooling: Slither, Echidna, pre-commit, CI

## Quick start
### Contracts (Foundry)
- Install: https://book.getfoundry.sh/getting-started/installation
- Init (optional): inside ./contracts run `forge init --force .`
- Build: `forge build`
- Test: `forge test -vvv`

### Dapp
- `cd dapp`
- Install deps (pnpm recommended): `pnpm i`
- Dev: `pnpm dev`

### Tooling
- Install pre-commit: `pipx install pre-commit` (或 `pip install pre-commit`)
- Enable: `pre-commit install`
- Slither & Echidna require Docker或本地安装，根据各自文档配置。

EOF

# Full MIT license
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 <YOUR NAME>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

cat > .gitignore << 'EOF'
# Node / Next.js
node_modules/
.next/
out/
.env*
# Foundry/Hardhat
cache/
artifacts/
lib/
broadcast/
# Python (some tools)
__pycache__/
*.pyc
# OS
.DS_Store
Thumbs.db
# Logs
*.log
EOF

cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: end-of-file-fixer
      - id: trailing-whitespace
      - id: check-yaml
      - id: check-merge-conflict

  - repo: https://github.com/prettier/prettier
    rev: 3.3.3
    hooks:
      - id: prettier
        additional_dependencies: [prettier@3.3.3]
        files: "\.(js|ts|tsx|json|md|yaml|yml)$"
EOF

# --- GitHub Actions (minimal) ---
cat > .github/workflows/ci-contracts.yml << 'EOF'
name: CI Contracts
on:
  push: { paths: ["contracts/**", ".github/workflows/ci-contracts.yml"] }
  pull_request: { paths: ["contracts/**", ".github/workflows/ci-contracts.yml"] }

jobs:
  foundry:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1
        with:
          version: nightly
      - name: Build & Test
        working-directory: contracts
        run: |
          forge --version
          forge build
          forge test -vvv
EOF

cat > .github/workflows/ci-dapp.yml << 'EOF'
name: CI Dapp
on:
  push: { paths: ["dapp/**", ".github/workflows/ci-dapp.yml"] }
  pull_request: { paths: ["dapp/**", ".github/workflows/ci-dapp.yml"] }

jobs:
  node:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - uses: pnpm/action-setup@v4
        with:
          version: 9
      - name: Install & Lint & Build
        working-directory: dapp
        run: |
          pnpm i
          pnpm run -s lint || true
          pnpm run -s build || true
EOF

# --- Contracts placeholders (Foundry-friendly) ---
cat > contracts/Counter.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Counter {
    uint256 public number;
    function set(uint256 n) external { number = n; }
    function inc() external { number += 1; }
}
EOF

cat > test/Counter.t.sol << 'EOF'
// SPDX-License-Identifier: MIT
// Foundry test (requires forge)
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../contracts/Counter.sol";

contract CounterTest is Test {
    Counter c;
    function setUp() public { c = new Counter(); }
    function testInc() public { c.inc(); assertEq(c.number(), 1); }
}
EOF

cat > script/Deploy.s.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Script.sol";
import "../contracts/Counter.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        new Counter();
        vm.stopBroadcast();
    }
}
EOF

# --- Notes placeholders ---
touch notes/evm/.gitkeep notes/consensus/.gitkeep notes/defispecs/.gitkeep

# --- Audit / reports placeholders ---
touch audits/.gitkeep reports/.gitkeep

# --- Tools config ---
cat > tools/slither.config.json << 'EOF'
{
  "detectors_to_exclude": ["assembly", "low-level-calls"],
  "filter_paths": ["lib", "node_modules"]
}
EOF

cat > tools/echidna.yaml << 'EOF'
testMode: assertion
seed: 1
shrinkLimit: 500
seqLen: 50
EOF

# --- Dapp: Next.js + wagmi + viem skeleton ---
cat > dapp/package.json << 'EOF'
{
  "name": "web3-journey-dapp",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint ."
  },
  "dependencies": {
    "@tanstack/react-query": "^5.51.0",
    "next": "^14.2.5",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "viem": "^2.13.0",
    "wagmi": "^2.12.0"
  },
  "devDependencies": {
    "eslint": "^9.9.0",
    "typescript": "^5.6.2"
  }
}
EOF

cat > dapp/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "Bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "preserve",
    "strict": true,
    "baseUrl": ".",
    "paths": { "@/*": ["./*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
EOF

cat > dapp/next-env.d.ts << 'EOF'
/// <reference types="next" />
/// <reference types="next/image-types/global" />
// NOTE: This file should not be edited
EOF

cat > dapp/src/lib/wagmi.ts << 'EOF'
"use client";

import { http, createConfig } from "wagmi";
import { mainnet, sepolia, hardhat, localhost } from "wagmi/chains";
import { injected } from "wagmi/connectors";

export const config = createConfig({
  chains: [localhost, hardhat, sepolia, mainnet],
  transports: {
    [localhost.id]: http("http://localhost:8545"),
    [hardhat.id]: http("http://127.0.0.1:8545"),
    [sepolia.id]: http(),
    [mainnet.id]: http()
  },
  connectors: [injected()]
});
EOF

cat > dapp/app/providers.tsx << 'EOF'
"use client";

import { PropsWithChildren } from "react";
import { WagmiProvider } from "wagmi";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { config } from "@/src/lib/wagmi";

const queryClient = new QueryClient();

export default function Providers({ children }: PropsWithChildren) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    </WagmiProvider>
  );
}
EOF

cat > dapp/app/layout.tsx << 'EOF'
import Providers from "./providers";

export const metadata = { title: "web3-journey dapp" };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body style={{ margin: 0 }}>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
EOF

cat > dapp/app/page.tsx << 'EOF'
"use client";

import { useAccount, useConnect, useDisconnect } from "wagmi";

export default function Home() {
  const { address, isConnected } = useAccount();
  const { connectors, connect, status, error } = useConnect();
  const { disconnect } = useDisconnect();

  return (
    <main style={{ padding: 24, fontFamily: "ui-sans-serif, system-ui" }}>
      <h1>web3-journey dapp (wagmi + viem)</h1>

      {!isConnected ? (
        <>
          <p>Connect a wallet:</p>
          {connectors.map((c) => (
            <button
              key={c.uid}
              onClick={() => connect({ connector: c })}
              disabled={!c.ready || status === "pending"}
              style={{ marginRight: 8, padding: "8px 12px" }}
            >
              {c.name}{!c.ready ? " (not ready)" : ""}
            </button>
          ))}
          {status !== "idle" && <p>Status: {status}</p>}
          {error && <p style={{ color: "crimson" }}>{error.message}</p>}
        </>
      ) : (
        <>
          <p>Connected: {address}</p>
          <button onClick={() => disconnect()} style={{ padding: "8px 12px" }}>
            Disconnect
          </button>
        </>
      )}
    </main>
  );
}
EOF

# --- Git keepers for empty dirs ---
touch contracts/.gitkeep script/.gitkeep test/.gitkeep tools/.gitkeep dapp/app/.gitkeep

echo "✅ Scaffolded with: MIT license (full text) + wagmi/viem dapp"
echo
echo "Next steps:"
echo "  1) git init && git add . && git commit -m 'init: web3-journey scaffold (wagmi/viem + MIT)'"
echo "  2) pre-commit install   (pipx install pre-commit 或 pip install pre-commit 后执行)"
echo "  3) Contracts: (可选) 在 contracts/ 里运行: forge init --force . && forge build && forge test"
echo "  4) Dapp: cd dapp && pnpm i && pnpm dev"
