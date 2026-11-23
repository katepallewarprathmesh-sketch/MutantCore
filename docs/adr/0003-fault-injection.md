# ADR-0003: Start with targeted seed faults, then MCY

Status: Accepted; MCY integration pending.

Initial manually injected ALU, decode, and branch faults provide a quick sensitivity check of the directed program. These three hand-selected mutants are not a representative MCY sample and cannot substantiate a mutation score. The planned MCY campaign will use Yosys-generated mutants, classify all non-equivalent survivors, and report raw counts as well as the score.
