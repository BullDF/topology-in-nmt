"""
Extract encoder self-attention maps for all 2000 sentence pairs in both directions.

For each sentence pair:
1. Run EN → FR translation, extract English encoder attention
2. Run FR → EN translation, extract French encoder attention

Saves results with checkpointing to avoid data loss.
"""

import torch
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
import pandas as pd
import numpy as np
from pathlib import Path
import pickle
from tqdm import tqdm
import time

def extract_encoder_attention(text, src_lang, tgt_lang, tokenizer, model, device):
    """
    Extract encoder self-attention for a given source text.

    Args:
        text: Source text string
        src_lang: Source language code (e.g., 'eng_Latn', 'fra_Latn')
        tgt_lang: Target language code (e.g., 'fra_Latn', 'eng_Latn')
        tokenizer: NLLB tokenizer
        model: NLLB model
        device: torch device

    Returns:
        dict with keys:
            - tokens: List of source tokens
            - encoder_attention: Encoder self-attention (num_layers, num_heads, seq_len, seq_len)
            - translation: Generated translation text
    """
    # Set source language
    tokenizer.src_lang = src_lang

    # Tokenize input
    inputs = tokenizer(text, return_tensors="pt").to(device)

    # Get target language BOS token
    tgt_lang_id = tokenizer.convert_tokens_to_ids(tgt_lang)

    # Generate translation with attention output
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            forced_bos_token_id=tgt_lang_id,
            output_attentions=True,
            return_dict_in_generate=True,
            max_length=128
        )

    # Extract encoder attention (available in encoder_attentions)
    # Shape: (num_layers, batch_size, num_heads, seq_len, seq_len)
    encoder_attention = outputs.encoder_attentions
    encoder_attention = torch.stack([layer.squeeze(0) for layer in encoder_attention])  # (num_layers, num_heads, seq_len, seq_len)

    # Decode tokens
    input_tokens = tokenizer.convert_ids_to_tokens(inputs.input_ids[0].cpu())
    translation = tokenizer.decode(outputs.sequences[0], skip_special_tokens=True)

    return {
        'tokens': input_tokens,
        'encoder_attention': encoder_attention.cpu().numpy(),
        'translation': translation
    }


def save_checkpoint(results, output_path, checkpoint_num):
    """Save checkpoint to avoid losing progress."""
    checkpoint_path = output_path.parent / f"{output_path.stem}_checkpoint_{checkpoint_num}.pkl"
    with open(checkpoint_path, 'wb') as f:
        pickle.dump(results, f)
    print(f"  💾 Checkpoint saved: {checkpoint_path.name}")


def main():
    print("=" * 80)
    print("Extracting Encoder Attention Maps for All 2000 Sentence Pairs")
    print("=" * 80)
    print()

    # Verify we're in the correct directory
    if not Path("../models/nllb-600M").exists():
        print("ERROR: Model directory not found!")
        print("Please run this script from the 'code/' directory:")
        print("  cd code")
        print("  python3 07_extract_all_attention.py")
        return

    print(f"Current directory: {Path.cwd()}")
    print()

    # Configuration
    CHECKPOINT_INTERVAL = 100  # Save checkpoint every N examples
    OUTPUT_DIR = Path("../data/attention_maps")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    OUTPUT_FILE = OUTPUT_DIR / "all_encoder_attention.pkl"

    # Device setup
    if torch.cuda.is_available():
        device = torch.device("cuda")
        print("✓ Using CUDA (NVIDIA GPU)")
    elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
        device = torch.device("mps")
        print("✓ Using MPS (Apple Silicon)")
    else:
        device = torch.device("cpu")
        print("✓ Using CPU")
    print()

    # Load model and tokenizer
    model_path = "../models/nllb-600M"
    print(f"Loading model from {model_path}...")
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    model = AutoModelForSeq2SeqLM.from_pretrained(
        model_path,
        attn_implementation="eager"  # Required for extracting attention weights
    ).to(device)
    model.eval()
    print("✓ Model loaded successfully!")
    print()

    # Load data
    data_path = Path("../data/sentence_pairs.pkl")
    print(f"Loading data from {data_path}...")
    data = pd.read_pickle(data_path)
    df = pd.DataFrame(data)
    df = df.rename(columns={'english': 'en', 'french': 'fr'})
    print(f"✓ Loaded {len(df)} sentence pairs")
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

    # Extract attention for all sentence pairs
    print(f"Extracting attention maps for {len(df)} sentence pairs...")
    print(f"Progress will be saved every {CHECKPOINT_INTERVAL} examples")
    print()

    start_time = time.time()

    for idx in tqdm(range(start_idx, len(df)), desc="Processing", unit="pair"):
        en_text = df.iloc[idx]['en']
        fr_text = df.iloc[idx]['fr']

        try:
            # Extract English encoder attention (EN → FR)
            en_result = extract_encoder_attention(
                text=en_text,
                src_lang='eng_Latn',
                tgt_lang='fra_Latn',
                tokenizer=tokenizer,
                model=model,
                device=device
            )

            # Extract French encoder attention (FR → EN)
            fr_result = extract_encoder_attention(
                text=fr_text,
                src_lang='fra_Latn',
                tgt_lang='eng_Latn',
                tokenizer=tokenizer,
                model=model,
                device=device
            )

            # Store results
            results.append({
                'idx': idx,
                'en_text': en_text,
                'fr_text': fr_text,
                'en_tokens': en_result['tokens'],
                'fr_tokens': fr_result['tokens'],
                'en_attention': en_result['encoder_attention'],
                'fr_attention': fr_result['encoder_attention'],
                'en_translation': en_result['translation'],
                'fr_translation': fr_result['translation']
            })

            # Save checkpoint periodically
            if (idx + 1) % CHECKPOINT_INTERVAL == 0:
                save_checkpoint(results, OUTPUT_FILE, idx + 1)

        except Exception as e:
            print(f"\n⚠️  Error processing pair {idx}: {e}")
            print(f"   EN: {en_text[:60]}...")
            print(f"   FR: {fr_text[:60]}...")
            continue

    elapsed_time = time.time() - start_time

    # Save final results
    print()
    print("=" * 80)
    print(f"✓ Extraction complete! Processed {len(results)} sentence pairs")
    print(f"⏱️  Total time: {elapsed_time / 60:.1f} minutes ({elapsed_time / len(results):.2f} sec/pair)")
    print()

    print(f"Saving final results to {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'wb') as f:
        pickle.dump(results, f)
    print(f"✓ Saved to {OUTPUT_FILE}")

    # Print summary statistics
    file_size_mb = OUTPUT_FILE.stat().st_size / (1024 * 1024)
    print()
    print("=" * 80)
    print("Summary Statistics")
    print("=" * 80)
    print(f"Total sentence pairs: {len(results)}")
    print(f"Output file size: {file_size_mb:.1f} MB")
    print(f"Average attention matrix shape:")
    if results:
        sample = results[0]
        print(f"  English: {sample['en_attention'].shape}")
        print(f"  French:  {sample['fr_attention'].shape}")
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
