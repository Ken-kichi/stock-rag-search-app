# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A stock RAG (Retrieval-Augmented Generation) search application written in Python. The project is in its initial scaffolding stage.

- Python 3.11 (managed via `.python-version`)
- Packaged with `pyproject.toml` (no external dependencies yet)

## Commands

```bash
# Run the app
python main.py

# Install dependencies (after adding them to pyproject.toml)
pip install -e .
```

## Architecture

Currently a single entry point: `main.py`. As the RAG pipeline is built out, expect to add:
- Document ingestion / embedding generation for stock data
- A vector store for similarity search
- A retrieval + generation pipeline wiring embeddings to an LLM
