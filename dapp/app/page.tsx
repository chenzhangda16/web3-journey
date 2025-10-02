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
