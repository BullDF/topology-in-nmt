"""
Step 3: Download and save NLLB-200-distilled-1.3B model
This is the 1.3B parameter NLLB model (distilled from 54B)
Saves model locally to avoid re-downloading
"""

from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
import os

print("=" * 60)
print("Downloading NLLB-200-distilled-1.3B model...")
print("=" * 60)

# Model identifier on HuggingFace
model_name = "facebook/nllb-200-distilled-1.3B"
print(f"\nModel: {model_name}")
print("This may take a few minutes (model is ~5.5GB)...")

# Download tokenizer
print("\n[1/2] Downloading tokenizer...")
tokenizer = AutoTokenizer.from_pretrained(model_name)
print("✓ Tokenizer loaded")

# Download model
print("\n[2/2] Downloading model...")
model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
print("✓ Model loaded")

# Save to local directory
print("\n" + "=" * 60)
print("Saving model and tokenizer to disk...")
print("=" * 60)

save_dir = "../models/nllb-1.3B"
os.makedirs(save_dir, exist_ok=True)

tokenizer.save_pretrained(save_dir)
model.save_pretrained(save_dir)

print(f"✓ Saved to: {save_dir}")
print(f"  - Tokenizer: {save_dir}/tokenizer_config.json")
print(f"  - Model: {save_dir}/model.safetensors")

print("\n" + "=" * 60)
print("SUCCESS! Model is ready to use.")
print("=" * 60)

print("\n" + "=" * 60)
print("Model Information:")
print("=" * 60)
print(f"Model name: NLLB-200-distilled-1.3B")
print(f"Parameters: ~1.3B")
print(f"Supported languages: 200 languages")
print(f"Architecture: Sequence-to-sequence transformer")
print(f"Distilled from: NLLB-200-54B (performs better than dense 1.3B)")
print(f"\nMemory requirements:")
print(f"  - Inference (float16): ~4-5 GB VRAM")
print(f"  - Inference (float32): ~8-10 GB VRAM")
print(f"\nTo load later:")
print(f"  from transformers import AutoTokenizer, AutoModelForSeq2SeqLM")
print(f"  tokenizer = AutoTokenizer.from_pretrained('{save_dir}')")
print(f"  model = AutoModelForSeq2SeqLM.from_pretrained('{save_dir}')")
print(f"\nNext: See 04_explore_model.ipynb for model testing and exploration")
