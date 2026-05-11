# Literature Review Blog Style

## Goal

Each literature review should read like a living survey chapter: compact enough for timely updates, but structured enough to become a durable knowledge base. The unit of organization is the field's ideas, not the arrival order of PDFs.

## Rewrite Checklist

- Identify the review's central question: e.g. "How do we quantize LLMs below 8 bits without losing downstream quality?"
- Build a concept graph: nodes are ideas, algorithms, metrics, datasets, failure modes, and papers; edges are "extends", "criticizes", "solves", "assumes", "evaluates", or "breaks under".
- Decide whether the new paper adds a new node, changes an edge, or forces a new top-level section.
- Rewrite section introductions so the new paper is part of the explanation, not an addendum.
- Add equations or pseudocode where the paper's contribution is mathematical or algorithmic.
- Add newly important cited works to `## References`, even if their PDFs are not in `inbox/papers`.

## Section Patterns

### Overview

Start with the deployment or scientific pressure behind the field. Then summarize the main conflict or bottleneck.

Example shape:

```mdx
Quantization asks how far we can reduce numeric precision before the model's computation stops approximating the full-precision network. In LLMs the bottleneck is not only arithmetic; it is memory bandwidth, activation outliers, KV-cache growth, and the mismatch between local calibration losses and end-task behavior.
```

### Conceptual Map

Use bullets or short subsections to show families:

- **PTQ:** cheap, calibration-based, usually local.
- **QAT:** end-to-end objective alignment, but expensive.
- **Forward-only / zeroth-order QAT:** keeps QAT's end-to-end target while avoiding backpropagation.

Then explain how papers move the map.

### Mathematical Setup

Include the generic objective before specialized methods:

```mdx
Q_\phi(W) = s \left(\mathrm{clip}\left(\left\lfloor W/s \right\rceil + z, q_{\min}, q_{\max}\right) - z\right)
```

Then describe what each paper changes: rounding, scales, clipping, transformations, adapters, reconstruction losses, policy objectives, etc.

### Algorithms and Design Patterns

Prefer reusable patterns over paper-specific prose:

```mdx
1. Keep full-precision shadow weights $W$.
2. Run the forward pass through quantized weights $Q_\phi(W)$.
3. Estimate or backpropagate an update for $W$ and quantizer parameters $\phi$.
4. Evaluate the deployed model using only $Q_\phi(W)$.
```

### Empirical Picture

Report what the evidence supports:

- Which model families were tested?
- Which bit widths matter?
- Which metrics are credible?
- Which baselines were strongest?
- Did the method work in zero-shot, instruction tuning, downstream fine-tuning, or long-context settings?

### Open Problems

Good open problems are technical:

- objective mismatch
- activation outliers
- kernel support
- calibration data representativeness
- evaluation beyond perplexity
- interactions with PEFT, MoE routing, KV cache, or RLHF

## References Format

Use a compact bibliography. Mark processed inbox papers with `paper-file` and `paper-hash`; leave other cited works unmarked.

```mdx
## References

- Zechun Liu et al. "LLM-QAT: Data-Free Quantization Aware Training for Large Language Models." Findings of ACL, 2024.
  {/* paper-file: 2024.findings-acl.26.pdf paper-hash: aad88e777fd4 */}
- Guangxuan Xiao et al. "SmoothQuant: Accurate and Efficient Post-Training Quantization for Large Language Models." ICML, 2023.
```

If a reference has an arXiv ID, include it when known. Do not invent venue metadata.
