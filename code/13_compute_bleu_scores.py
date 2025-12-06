"""
Compute BLEU scores for all 2000 sentence pairs.

Compares:
- EN→FR: Generated French (en_translation) with reference French (fr_text)
- FR→EN: Generated English (fr_translation) with reference English (en_text)

Saves results to CSV.
"""

import pickle
import pandas as pd
from pathlib import Path
from sacrebleu import sentence_bleu
from tqdm import tqdm


def compute_bleu_scores(en_text, fr_text, en_translation, fr_translation):
    """
    Compute BLEU scores for both translation directions.

    Args:
        en_text: Original English text (reference for FR→EN)
        fr_text: Original French text (reference for EN→FR)
        en_translation: Generated French from English (hypothesis for EN→FR)
        fr_translation: Generated English from French (hypothesis for FR→EN)

    Returns:
        dict with BLEU scores
    """
    # EN→FR: Compare generated French with reference French
    bleu_en_fr = sentence_bleu(en_translation, [fr_text]).score

    # FR→EN: Compare generated English with reference English
    bleu_fr_en = sentence_bleu(fr_translation, [en_text]).score

    # Average BLEU
    bleu_avg = (bleu_en_fr + bleu_fr_en) / 2

    return {
        'bleu_en_fr': bleu_en_fr,
        'bleu_fr_en': bleu_fr_en,
        'bleu_avg': bleu_avg
    }


def main():
    print("=" * 80)
    print("Computing BLEU Scores for All Sentence Pairs")
    print("=" * 80)
    print()

    # Load TDA results (contains translations)
    INPUT_PATH = Path("../data/tda_results/tda_results_last_layer_filtered.pkl")
    OUTPUT_PATH = Path("../data/bleu_scores.csv")

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
            fr_text=example['fr_text'],
            en_translation=example['en_translation'],
            fr_translation=example['fr_translation']
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
    print("EN→FR BLEU:")
    print(f"  Min:    {df_bleu['bleu_en_fr'].min():.2f}")
    print(f"  Max:    {df_bleu['bleu_en_fr'].max():.2f}")
    print(f"  Mean:   {df_bleu['bleu_en_fr'].mean():.2f}")
    print(f"  Median: {df_bleu['bleu_en_fr'].median():.2f}")
    print(f"  Std:    {df_bleu['bleu_en_fr'].std():.2f}")
    print()

    print("FR→EN BLEU:")
    print(f"  Min:    {df_bleu['bleu_fr_en'].min():.2f}")
    print(f"  Max:    {df_bleu['bleu_fr_en'].max():.2f}")
    print(f"  Mean:   {df_bleu['bleu_fr_en'].mean():.2f}")
    print(f"  Median: {df_bleu['bleu_fr_en'].median():.2f}")
    print(f"  Std:    {df_bleu['bleu_fr_en'].std():.2f}")
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
