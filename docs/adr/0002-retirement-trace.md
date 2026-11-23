# ADR-0002: Compare per-retirement trace

Status: Accepted.

Use RVFI fields for per-instruction PC, instruction, source/destination register effects and memory effects rather than only final architectural state. This makes the first divergence observable. Current use is an interface smoke; Spike matching is not yet implemented. CSR fields are captured only in the RTL interface and are not yet compared.
