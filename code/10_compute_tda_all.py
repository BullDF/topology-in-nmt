"""
Compute persistent homology and Wasserstein distances for all 2000 sentence pairs.

For each sentence pair:
1. Build distance matrices from English and French encoder attention
2. Compute Vietoris-Rips persistent homology (β₀, β₁)
3. Calculate Wasserstein distance between English and French persistence diagrams

Saves results with checkpointing to avoid data loss.
"""

import numpy as np
from pathlib import Path
import pickle
from tqdm import tqdm
import time
import argparse
import warnings

# TDA libraries (Scikit-TDA)
from ripser import ripser
from persim import wasserstein

# Suppress warnings about infinite death times in persistence diagrams
# (This is expected for H0 diagrams - one component persists forever)
warnings.filterwarnings('ignore', message='.*non-finite death times.*')


def build_distance_matrix(attention, tokens, layer=-1, filter_special=True):
    """
    Build distance matrix from attention weights.

    Args:
        attention: Attention tensor (num_layers, num_heads, seq_len, seq_len)
        tokens: List of token strings
        layer: Which layer to use (-1 for last layer, or 0-11 for specific layer)
        filter_special: Whether to filter out special tokens

    Returns:
        distance_matrix: (N, N) array where N = number of tokens (or content tokens if filtered)
        filtered_tokens: List of token strings (content tokens if filtered, all tokens otherwise)
    """
    # 1. Extract specified layer and average over heads
    attn = attention[layer].mean(axis=0)  # (seq_len, seq_len)

    # 2. Filter special tokens (optional)
    if filter_special:
        special_tokens = {'</s>', '<s>', '<pad>', 'eng_Latn', 'fra_Latn'}
        content_mask = np.array([tok not in special_tokens for tok in tokens])

        if sum(content_mask) > 0:  # Only filter if there are content tokens
            # Filter attention matrix
            attn_filtered = attn[content_mask][:, content_mask]
            filtered_tokens = [tok for tok, keep in zip(tokens, content_mask) if keep]

            # 3. Renormalize
            row_sums = attn_filtered.sum(axis=1, keepdims=True)
            attn_filtered = attn_filtered / row_sums
        else:
            # No content tokens, use original
            attn_filtered = attn
            filtered_tokens = tokens
    else:
        # No filtering, use all tokens
        attn_filtered = attn
        filtered_tokens = tokens

    # 4. Symmetrize (make undirected)
    attn_sym = (attn_filtered + attn_filtered.T) / 2

    # 5. Convert to distance: d = 1 - attention
    distance_matrix = 1 - attn_sym

    # Ensure diagonal is 0
    np.fill_diagonal(distance_matrix, 0)

    return distance_matrix, filtered_tokens


def compute_persistence_and_wasserstein(en_attention, en_tokens, fr_attention, fr_tokens,
                                        layer=-1, filter_special=True):
    """
    Compute persistent homology and Wasserstein distance for a sentence pair.

    Args:
        en_attention: English encoder attention (num_layers, num_heads, seq_len, seq_len)
        en_tokens: English token list
        fr_attention: French encoder attention (num_layers, num_heads, seq_len, seq_len)
        fr_tokens: French token list
        layer: Which layer to use
        filter_special: Whether to filter special tokens

    Returns:
        dict with Wasserstein distances and persistence diagrams
    """
    # Build distance matrices
    en_dist, en_filtered_tokens = build_distance_matrix(en_attention, en_tokens, layer, filter_special)
    fr_dist, fr_filtered_tokens = build_distance_matrix(fr_attention, fr_tokens, layer, filter_special)

    # Compute persistence using ripser
    en_result = ripser(en_dist, maxdim=1, distance_matrix=True)
    fr_result = ripser(fr_dist, maxdim=1, distance_matrix=True)

    en_diagrams = en_result['dgms']  # [H0, H1]
    fr_diagrams = fr_result['dgms']

    # Compute Wasserstein distances
    w_dist_h0 = wasserstein(en_diagrams[0], fr_diagrams[0])
    w_dist_h1 = wasserstein(en_diagrams[1], fr_diagrams[1])
    total_w_dist = w_dist_h0 + w_dist_h1

    return {
        'wasserstein_distance': total_w_dist,
        'wasserstein_h0': w_dist_h0,
        'wasserstein_h1': w_dist_h1,
        'en_diagrams': en_diagrams,
        'fr_diagrams': fr_diagrams,
        'en_num_tokens': len(en_filtered_tokens),
        'fr_num_tokens': len(fr_filtered_tokens),
        'en_h0_features': len(en_diagrams[0]),
        'en_h1_features': len(en_diagrams[1]),
        'fr_h0_features': len(fr_diagrams[0]),
        'fr_h1_features': len(fr_diagrams[1])
    }


def save_checkpoint(results, output_path, checkpoint_num):
    """Save checkpoint to avoid losing progress."""
    checkpoint_path = output_path.parent / f"{output_path.stem}_checkpoint_{checkpoint_num}.pkl"
    with open(checkpoint_path, 'wb') as f:
        pickle.dump(results, f)
    print(f"  💾 Checkpoint saved: {checkpoint_path.name}")


def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Compute TDA metrics for all sentence pairs')
    parser.add_argument('--layer', type=int, default=-1,
                        help='Which encoder layer to use (-1 for last layer, 0-11 for specific layer)')
    parser.add_argument('--filter-special', action='store_true', default=True,
                        help='Filter out special tokens (default: True)')
    parser.add_argument('--no-filter-special', dest='filter_special', action='store_false',
                        help='Do not filter special tokens')
    parser.add_argument('--checkpoint-interval', type=int, default=100,
                        help='Save checkpoint every N examples (default: 100)')
    args = parser.parse_args()

    print("=" * 80)
    print("Computing Persistent Homology and Wasserstein Distances")
    print("=" * 80)
    print(f"Configuration:")
    print(f"  Layer: {args.layer} ({'last layer' if args.layer == -1 else f'layer {args.layer}'})")
    print(f"  Filter special tokens: {args.filter_special}")
    print(f"  Checkpoint interval: {args.checkpoint_interval}")
    print()

    # Configuration
    INPUT_PATH = Path("../data/attention_maps/all_encoder_attention.pkl")
    OUTPUT_DIR = Path("../data/tda_results")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Create output filename based on configuration
    layer_str = f"layer{args.layer}" if args.layer >= 0 else "last_layer"
    filter_str = "filtered" if args.filter_special else "unfiltered"
    OUTPUT_FILE = OUTPUT_DIR / f"tda_results_{layer_str}_{filter_str}.pkl"

    print(f"Input: {INPUT_PATH}")
    print(f"Output: {OUTPUT_FILE}")
    print()

    # Load attention data
    print(f"Loading attention data from {INPUT_PATH}...")
    print(f"File size: {INPUT_PATH.stat().st_size / (1024**3):.2f} GB")
    with open(INPUT_PATH, 'rb') as f:
        attention_data = pickle.load(f)
    print(f"✓ Loaded {len(attention_data)} sentence pairs")
    print()

    # Check for existing checkpoint to resume from
    start_idx = 0
    results = []
    checkpoint_files = sorted(OUTPUT_DIR.glob(f"{OUTPUT_FILE.stem}_checkpoint_*.pkl"))
    if checkpoint_files:
        latest_checkpoint = checkpoint_files[-1]
        print(f"Found checkpoint: {latest_checkpoint.name}")
        with open(latest_checkpoint, 'rb') as f:
            results = pickle.load(f)
        start_idx = len(results)
        print(f"✓ Resuming from example {start_idx}")
        print()

    # Process all sentence pairs
    print(f"Computing TDA metrics for {len(attention_data)} sentence pairs...")
    print(f"Progress will be saved every {args.checkpoint_interval} examples")
    print()

    start_time = time.time()

    for idx in tqdm(range(start_idx, len(attention_data)), desc="Processing", unit="pair"):
        example = attention_data[idx]

        try:
            # Compute persistence and Wasserstein distance
            tda_metrics = compute_persistence_and_wasserstein(
                en_attention=example['en_attention'],
                en_tokens=example['en_tokens'],
                fr_attention=example['fr_attention'],
                fr_tokens=example['fr_tokens'],
                layer=args.layer,
                filter_special=args.filter_special
            )

            # Store results
            results.append({
                'idx': idx,
                'en_text': example['en_text'],
                'fr_text': example['fr_text'],
                'en_translation': example['en_translation'],
                'fr_translation': example['fr_translation'],
                **tda_metrics
            })

            # Save checkpoint periodically
            if (idx + 1) % args.checkpoint_interval == 0:
                save_checkpoint(results, OUTPUT_FILE, idx + 1)

        except Exception as e:
            print(f"\n⚠️  Error processing pair {idx}: {e}")
            print(f"   EN: {example['en_text'][:60]}...")
            print(f"   FR: {example['fr_text'][:60]}...")
            continue

    elapsed_time = time.time() - start_time

    # Save final results
    print()
    print("=" * 80)
    print(f"✓ Processing complete! Computed TDA metrics for {len(results)} sentence pairs")
    print(f"⏱️  Total time: {elapsed_time / 60:.1f} minutes ({elapsed_time / len(results):.2f} sec/pair)")
    print()

    print(f"Saving final results to {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'wb') as f:
        pickle.dump(results, f)
    print(f"✓ Saved to {OUTPUT_FILE}")

    # Print summary statistics
    file_size_mb = OUTPUT_FILE.stat().st_size / (1024 * 1024)
    w_dists = [r['wasserstein_distance'] for r in results]
    h0_counts_en = [r['en_h0_features'] for r in results]
    h1_counts_en = [r['en_h1_features'] for r in results]
    h0_counts_fr = [r['fr_h0_features'] for r in results]
    h1_counts_fr = [r['fr_h1_features'] for r in results]

    print()
    print("=" * 80)
    print("Summary Statistics")
    print("=" * 80)
    print(f"Total sentence pairs: {len(results)}")
    print(f"Output file size: {file_size_mb:.1f} MB")
    print()
    print(f"Wasserstein Distance:")
    print(f"  Min:    {np.min(w_dists):.6f}")
    print(f"  Max:    {np.max(w_dists):.6f}")
    print(f"  Mean:   {np.mean(w_dists):.6f}")
    print(f"  Median: {np.median(w_dists):.6f}")
    print()
    print(f"H0 Features (β₀):")
    print(f"  English - Mean: {np.mean(h0_counts_en):.1f}, Max: {np.max(h0_counts_en)}")
    print(f"  French  - Mean: {np.mean(h0_counts_fr):.1f}, Max: {np.max(h0_counts_fr)}")
    print()
    print(f"H1 Features (β₁):")
    print(f"  English - Mean: {np.mean(h1_counts_en):.1f}, Max: {np.max(h1_counts_en)}")
    print(f"  French  - Mean: {np.mean(h1_counts_fr):.1f}, Max: {np.max(h1_counts_fr)}")
    print()

    # Clean up checkpoint files
    print("Cleaning up checkpoint files...")
    for checkpoint_file in OUTPUT_DIR.glob(f"{OUTPUT_FILE.stem}_checkpoint_*.pkl"):
        checkpoint_file.unlink()
        print(f"  🗑️  Removed {checkpoint_file.name}")

    print()
    print("=" * 80)
    print("✅ All done!")
    print("=" * 80)


if __name__ == "__main__":
    main()
