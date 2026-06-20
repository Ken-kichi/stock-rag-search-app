# IR資料 RAG検索・分析システム

複数企業のIR資料（決算短信・統合報告書・決算説明会資料）をAzure AI Searchでインデックス化し、LangGraphによるRAGパイプラインで企業分析・比較・投資情報提供を行うシステムです。

---

## 機能概要

- **単社分析モード** — 企業の強み・収益モデル・リスクをIR資料から抽出・要約
- **企業比較モード** — 複数企業を横断して財務指標・戦略を比較表示
- **投資情報モード** — 根拠となるIR箇所を引用した上で投資判断に必要な情報を提供
- **精度向上** — LangGraphによるクエリ変換・関連度評価・Corrective RAGループ

> **免責事項**
> 本システムが提供する情報はIR資料に基づく参考情報です。投資判断はご自身の責任で行ってください。本システムは金融商品取引法に基づく投資助言業登録を行っていません。

---

## システム構成

```
┌─────────────────────────────────────────────┐
│  Streamlit (Container Apps)                  │
│  単社分析 / 企業比較 / 投資情報 UI           │
└────────────────────┬────────────────────────┘
                     │ HTTP
┌────────────────────▼────────────────────────┐
│  FastAPI (Container Apps)                    │
│  LangGraph RAGパイプライン                   │
│  ┌──────────────────────────────────────┐   │
│  │ クエリ分類 → クエリ変換 → Retriever  │   │
│  │ → 関連度評価 → 回答生成 → 品質評価  │   │
│  └──────────────────────────────────────┘   │
└──────┬────────────────────┬─────────────────┘
       │                    │
┌──────▼──────┐    ┌────────▼────────┐
│ Azure AI    │    │ Azure OpenAI     │
│ Search      │    │ GPT-4o           │
│ Hybrid+RRF  │    │ text-embedding-  │
│ Semantic    │    │ 3-large          │
│ Ranker      │    └─────────────────┘
└─────────────┘
┌─────────────────────────────────────────────┐
│  Azure SQL Server                            │
│  企業マスタ / IR資料一覧 / ジョブ履歴        │
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│  Azure Blob Storage                          │
│  PDFファイル本体                             │
└─────────────────────────────────────────────┘
┌─────────────────────────────────────────────┐
│  Container Apps Jobs（バッチ）               │
│  PDF自動取得・インデックス更新               │
└─────────────────────────────────────────────┘
```

---

## 技術スタック

| レイヤー | 技術 |
|---|---|
| フロントエンド | Streamlit |
| バックエンド | FastAPI |
| RAGオーケストレーション | LangGraph |
| ベクトル検索 | Azure AI Search（Hybrid + Semantic Ranker） |
| LLM | Azure OpenAI（GPT-4o / text-embedding-3-large） |
| リレーショナルDB | Azure SQL Server |
| ストレージ | Azure Blob Storage |
| コンテナレジストリ | Azure Container Registry |
| ホスティング | Azure Container Apps |
| PDF取得バッチ | Azure Container Apps Jobs |
| IaCツール | Terraform |
| PDF解析 | PyMuPDF / pdfplumber |
| IR資料取得 | EDINET API |

---

## ディレクトリ構成

```
ir-rag/
├── frontend/                   # Streamlit アプリ
│   ├── app.py                  # メインエントリーポイント
│   ├── pages/
│   │   ├── single_analysis.py  # 単社分析モード
│   │   ├── comparison.py       # 企業比較モード
│   │   └── investment_info.py  # 投資情報モード
│   ├── components/
│   │   ├── company_selector.py # 企業選択サイドバー
│   │   └── citation_card.py    # 引用元表示コンポーネント
│   ├── Dockerfile
│   └── requirements.txt
│
├── backend/                    # FastAPI + LangGraph
│   ├── main.py                 # FastAPI エントリーポイント
│   ├── api/
│   │   ├── search.py           # 検索エンドポイント
│   │   └── companies.py        # 企業マスタエンドポイント
│   ├── rag/
│   │   ├── graph.py            # LangGraphグラフ定義
│   │   ├── nodes/
│   │   │   ├── classifier.py   # クエリ分類ノード
│   │   │   ├── query_transform.py  # クエリ変換ノード（HyDE・Multi-query）
│   │   │   ├── retriever.py    # Azure AI Search呼び出しノード
│   │   │   ├── evaluator.py    # 関連度評価ノード
│   │   │   ├── generator.py    # 回答生成ノード
│   │   │   └── quality_check.py  # Faithfulnessチェックノード
│   │   └── prompts/
│   │       ├── single.py       # 単社分析プロンプト
│   │       ├── comparison.py   # 比較プロンプト
│   │       └── investment.py   # 投資情報プロンプト
│   ├── db/
│   │   ├── models.py           # SQLAlchemyモデル
│   │   └── crud.py             # DB操作
│   ├── Dockerfile
│   └── requirements.txt
│
├── indexer/                    # PDF取得・インデックス構築バッチ
│   ├── main.py                 # バッチエントリーポイント
│   ├── fetchers/
│   │   ├── edinet.py           # EDINET APIクライアント
│   │   └── pdf_parser.py       # PDF解析（PyMuPDF / pdfplumber）
│   ├── indexing/
│   │   ├── chunker.py          # チャンキング処理
│   │   ├── embedder.py         # 埋め込み生成
│   │   └── search_client.py    # Azure AI Search投入
│   ├── Dockerfile
│   └── requirements.txt
│
├── infra/                      # インフラ定義（Terraform）
│   ├── main.tf                 # プロバイダー・バックエンド設定
│   ├── variables.tf            # 変数定義
│   ├── outputs.tf              # 出力値定義
│   ├── terraform.tfvars        # 変数値（gitignore対象）
│   ├── modules/
│   │   ├── container_apps/     # Container Apps / Jobs
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── search/             # Azure AI Search
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── sql/                # Azure SQL Server
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── storage/            # Blob Storage
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── openai/             # Azure OpenAI
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── scripts/
│       ├── deploy.sh
│       └── create_index.py     # インデックス初期作成スクリプト
│
├── docker-compose.yml          # ローカル開発用
└── README.md
```

---

## Azure AI Search インデックススキーマ

```json
{
  "fields": [
    { "name": "id",            "type": "Edm.String",        "key": true },
    { "name": "chunk_text",    "type": "Edm.String",        "searchable": true },
    { "name": "vector",        "type": "Collection(Edm.Single)", "dimensions": 1536 },
    { "name": "company_name",  "type": "Edm.String",        "filterable": true, "facetable": true },
    { "name": "ticker",        "type": "Edm.String",        "filterable": true },
    { "name": "fiscal_year",   "type": "Edm.String",        "filterable": true, "facetable": true },
    { "name": "doc_type",      "type": "Edm.String",        "filterable": true },
    { "name": "section",       "type": "Edm.String",        "filterable": true },
    { "name": "page_number",   "type": "Edm.Int32",         "filterable": true },
    { "name": "blob_url",      "type": "Edm.String" }
  ]
}
```

---

## LangGraphパイプライン

```
クエリ入力
    │
    ▼
[クエリ分類ノード]  →  単社 / 比較 / 投資情報 の3モードを判定
    │
    ▼
[クエリ変換ノード]  →  HyDE・Multi-query・メタデータフィルター生成
    │
    ▼
[Retrieverノード]   →  Azure AI Search（Hybrid + Semantic Ranker）
    │
    ▼
[関連度評価ノード]  →  不十分なら別クエリで再検索（Corrective RAG）
    │
    ▼
[回答生成ノード]    →  モード別プロンプト・引用元チャンク明示
    │
    ▼
[品質評価ノード]    →  Faithfulness チェック・免責文挿入（投資情報モード）
    │
    ▼
回答出力
```

---

## セットアップ

### 前提条件

- Python 3.11以上
- Docker / Docker Compose
- Azure CLI
- Terraform 1.7以上
- Azureサブスクリプション

### 環境変数

`.env` ファイルをプロジェクトルートに作成してください。

```env
# Azure OpenAI
AZURE_OPENAI_ENDPOINT=https://<your-resource>.openai.azure.com
AZURE_OPENAI_API_KEY=<your-key>
AZURE_OPENAI_DEPLOYMENT_CHAT=gpt-4o
AZURE_OPENAI_DEPLOYMENT_EMBEDDING=text-embedding-3-large

# Azure AI Search
AZURE_SEARCH_ENDPOINT=https://<your-resource>.search.windows.net
AZURE_SEARCH_API_KEY=<your-key>
AZURE_SEARCH_INDEX_NAME=ir-documents

# Azure SQL Server
SQL_SERVER=<your-server>.database.windows.net
SQL_DATABASE=ir_rag_db
SQL_USERNAME=<your-username>
SQL_PASSWORD=<your-password>

# Azure Blob Storage
AZURE_STORAGE_CONNECTION_STRING=<your-connection-string>
AZURE_STORAGE_CONTAINER=ir-pdfs

# EDINET API
EDINET_API_KEY=<your-key>
```

### ローカル開発

```bash
git clone https://github.com/<your-org>/ir-rag.git
cd ir-rag

cp .env.example .env
# .env を編集して各種キーを設定

docker compose up --build
```

アプリは `http://localhost:8501` で起動します。

### インデックス初期構築

```bash
# Azure AI Searchインデックスを作成
python infra/scripts/create_index.py

# 企業リストを指定してIR資料を取得・インデックス投入
docker compose run indexer python main.py --tickers 7203,9984,6758
```

---

## Azure へのデプロイ

```bash
# Container Registryにイメージをプッシュ
az acr build --registry <your-acr> --image ir-frontend:latest ./frontend
az acr build --registry <your-acr> --image ir-backend:latest ./backend
az acr build --registry <your-acr> --image ir-indexer:latest ./indexer

# Terraformでインフラをデプロイ
cd infra
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## 開発ロードマップ

- [x] システム設計・アーキテクチャ確定
- [ ] Azure AI Searchインデックス構築
- [ ] EDINET PDF取得・チャンキングパイプライン
- [ ] LangGraph RAGパイプライン実装
- [ ] Streamlit UI実装
- [ ] Container Appsデプロイ
- [ ] RAGASによる精度評価・チューニング
- [ ] Container Apps Jobsによる定期更新バッチ

---

## ライセンス

MIT License
