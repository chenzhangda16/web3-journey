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

