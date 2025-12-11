"""
Compute BLEU scores for all 2000 sentence pairs.

Compares:
- EN→ZH: Generated Chinese (en_translation) with reference Chinese (zh_text)
- ZH→EN: Generated English (zh_translation) with reference English (en_text)

Saves results to CSV.
"""

import pickle
import pandas as pd
from pathlib import Path
from sacrebleu import sentence_bleu
from tqdm import tqdm


def compute_bleu_scores(en_text, zh_text, en_translation, zh_translation):
    """
    Compute BLEU scores for both translation directions.

    Args:
        en_text: Original English text (reference for ZH→EN)
        zh_text: Original Chinese text (reference for EN→ZH)
        en_translation: Generated Chinese from English (hypothesis for EN→ZH)
        zh_translation: Generated English from Chinese (hypothesis for ZH→EN)

    Returns:
        dict with BLEU scores
    """
    # EN→ZH: Compare generated Chinese with reference Chinese
    bleu_en_zh = sentence_bleu(en_translation, [zh_text]).score

    # ZH→EN: Compare generated English with reference English
    bleu_zh_en = sentence_bleu(zh_translation, [en_text]).score

    # Average BLEU
    bleu_avg = (bleu_en_zh + bleu_zh_en) / 2

    return {
        'bleu_en_zh': bleu_en_zh,
        'bleu_zh_en': bleu_zh_en,
        'bleu_avg': bleu_avg
    }


def main():
    print("=" * 80)
    print("Computing BLEU Scores for All Sentence Pairs")
    print("=" * 80)
    print()

    # Load TDA results (contains translations)
    INPUT_PATH = Path("../data/tda_results_zh_en/tda_results_last_layer_filtered.pkl")
    OUTPUT_PATH = Path("../data/bleu_scores_zh_en.csv")

    print(f"Input:  {INPUT_PATH}")
    print(f"Output: {OUTPUT_PATH}")
    print()

    print(f"Loading data from {INPUT_PATH}...")
    print(f"File size: {INPUT_PATH.stat().st_size / (1024**2):.1f} MB")
    with open(INPUT_PATH, 'rb') as f:
        results = pickle.load(f)
    print(f"✓ Loaded {len(results)} sentence pairs")
    print()

    # Compute BLEU scores for all examples
    print(f"Computing BLEU scores for {len(results)} sentence pairs...")
    print()

    bleu_results = []
    for i, example in enumerate(tqdm(results, desc="Processing", unit="pair")):
        scores = compute_bleu_scores(
            en_text=example['en_text'],
            zh_text=example['zh_text'],
            en_translation=example['en_translation'],
            zh_translation=example['zh_translation']
        )

        bleu_results.append({
            'idx': i,
            **scores
        })

    print()
    print(f"✓ Computed BLEU scores for all {len(bleu_results)} pairs")
    print()

    # Convert to DataFrame
    df_bleu = pd.DataFrame(bleu_results)

    # Print summary statistics
    print("=" * 80)
    print("Summary Statistics")
    print("=" * 80)
    print()
    print("EN→ZH BLEU:")
    print(f"  Min:    {df_bleu['bleu_en_zh'].min():.2f}")
    print(f"  Max:    {df_bleu['bleu_en_zh'].max():.2f}")
    print(f"  Mean:   {df_bleu['bleu_en_zh'].mean():.2f}")
    print(f"  Median: {df_bleu['bleu_en_zh'].median():.2f}")
    print(f"  Std:    {df_bleu['bleu_en_zh'].std():.2f}")
    print()

    print("ZH→EN BLEU:")
    print(f"  Min:    {df_bleu['bleu_zh_en'].min():.2f}")
    print(f"  Max:    {df_bleu['bleu_zh_en'].max():.2f}")
    print(f"  Mean:   {df_bleu['bleu_zh_en'].mean():.2f}")
    print(f"  Median: {df_bleu['bleu_zh_en'].median():.2f}")
    print(f"  Std:    {df_bleu['bleu_zh_en'].std():.2f}")
    print()

    print("Average BLEU:")
    print(f"  Min:    {df_bleu['bleu_avg'].min():.2f}")
    print(f"  Max:    {df_bleu['bleu_avg'].max():.2f}")
    print(f"  Mean:   {df_bleu['bleu_avg'].mean():.2f}")
    print(f"  Median: {df_bleu['bleu_avg'].median():.2f}")
    print(f"  Std:    {df_bleu['bleu_avg'].std():.2f}")
    print()

    # Save to CSV
    print(f"Saving results to {OUTPUT_PATH}...")
    df_bleu.to_csv(OUTPUT_PATH, index=False)
    print(f"✓ Saved to {OUTPUT_PATH}")
    print(f"  Shape: {df_bleu.shape}")
    print(f"  Columns: {list(df_bleu.columns)}")
    print()

    print("=" * 80)
    print("✅ All done!")
    print("=" * 80)


if __name__ == "__main__":
    main()
