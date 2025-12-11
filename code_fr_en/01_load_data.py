"""
Step 1: Load WMT14 fr-en validation dataset (first 2000 examples)
Uses streaming mode to avoid downloading the entire dataset
2000 examples provides sufficient data for analysis
"""

from datasets import load_dataset, Dataset
import os

print("=" * 60)
print("Loading WMT14 fr-en validation dataset (first 2000 examples)...")
print("=" * 60)

# Use streaming mode to avoid downloading entire dataset
print("Streaming data (no full download needed)...")
stream = load_dataset(
    "wmt/wmt14",
    "fr-en",
    split="validation",
    streaming=True,
    trust_remote_code=True
)

# Take only first 2000 examples
print("Collecting first 2000 examples...")
examples = []
for i, example in enumerate(stream):
    if i >= 2000:
        break
    examples.append(example)
    if (i + 1) % 200 == 0:
        print(f"  Loaded {i + 1}/2000 examples...")

# Convert to Dataset object (preserve original structure)
validation_data = Dataset.from_list(examples)

print(f"\n✓ Validation subset loaded: {len(validation_data)} sentence pairs")

# Show example
print("\n" + "=" * 60)
print("Example sentence pair from validation set:")
print("=" * 60)
example = validation_data[0]["translation"]
print(f"English:  {example['en']}")
print(f"French:   {example['fr']}")

# Show data structure
print("\n" + "=" * 60)
print("Dataset structure:")
print("=" * 60)
print(f"Features: {validation_data.features}")
print(f"Column names: {validation_data.column_names}")

# Optional: Save to disk for faster loading later
print("\n" + "=" * 60)
print("Saving dataset to disk...")
print("=" * 60)

os.makedirs("../data", exist_ok=True)
validation_data.save_to_disk("../data/wmt14_fr-en_validation_2000")

print("✓ Saved validation subset to: ../data/wmt14_fr-en_validation_2000")

print("\n" + "=" * 60)
print("SUCCESS! Data is ready to use.")
print("=" * 60)
