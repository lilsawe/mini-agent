#!/usr/bin/env bash
# One-command setup for mini-agent conda environment
# Usage: bash setup.sh

set -e

ENV_NAME="mini-agent"

echo "==> Creating conda environment '${ENV_NAME}' with Python 3.11..."
conda env create -f environment.yml

echo ""
echo "==> Done! Activate with:"
echo "    conda activate ${ENV_NAME}"
echo ""
echo "==> Then set your API key and run:"
echo "    export DEEPSEEK_API_KEY='your-deepseek-api-key'"
echo "    python main.py"
