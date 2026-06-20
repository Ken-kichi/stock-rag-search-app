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
│  Streamlit + LangGraph (App Service B2)      │
│  単社分析 / 企業比較 / 投資情報 UI           │
│  ┌──────────────────────────────────────┐   │
│  │ クエリ分類 → クエリ変換 → Retriever  │   │
│  │ → 関連度評価 → 回答生成 → 品質評価  │   │
│  └──────────────────────────────────────┘   │
│  WebJobs（PDF取得バッチ・スケジュール実行）  │
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
```

---

## 技術スタック

| レイヤー | 技術 |
|---|---|
| フロントエンド | Streamlit |
| RAGオーケストレーション | LangGraph |
| ベクトル検索 | Azure AI Search（Hybrid + Semantic Ranker） |
| LLM | Azure OpenAI（GPT-4o / text-embedding-3-large） |
| リレーショナルDB | Azure SQL Server |
| ストレージ | Azure Blob Storage |
| ホスティング | Azure App Service B2 |
| PDF取得バッチ | App Service WebJobs |
| IaCツール | Terraform |
| PDF解析 | PyMuPDF / pdfplumber |
| IR資料取得 | EDINET API |

---

## App Service SKU

| App Service | SKU | 用途 | 月額目安 |
|---|---|---|---|
| ir-rag-app | B2（2コア・3.5GB） | Streamlit + LangGraph + WebJobs | 約3,600円 |

> 使用しないときは `az webapp stop --name ir-rag-app --resource-group ir-rag-rg` で停止するとコストを抑えられます。

---

## ディレクトリ構成

```
stock-rag-search-app/
├── app/                        # Streamlit + LangGraph（App Service B2）
│   ├── app.py                  # メインエントリーポイント
│   ├── pages/
│   │   ├── single_analysis.py  # 単社分析モード
│   │   ├── comparison.py       # 企業比較モード
│   │   └── investment_info.py  # 投資情報モード
│   ├── components/
│   │   ├── company_selector.py # 企業選択サイドバー
│   │   └── citation_card.py    # 引用元表示コンポーネント
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
│   ├── webjobs/                # App Service WebJobs（バッチ）
│   │   ├── run.py              # バッチエントリーポイント
│   │   └── settings.job        # スケジュール設定（cron式）
│   └── requirements.txt
│
├── indexer/                    # PDF取得・インデックス構築
│   ├── main.py                 # エントリーポイント
│   ├── fetchers/
│   │   ├── edinet.py           # EDINET APIクライアント
│   │   └── pdf_parser.py       # PDF解析（PyMuPDF / pdfplumber）
│   └── indexing/
│       ├── chunker.py          # チャンキング処理
│       ├── embedder.py         # 埋め込み生成
│       └── search_client.py    # Azure AI Search投入
│
├── infra/                      # インフラ定義（Terraform）
│   ├── main.tf                 # プロバイダー・tfstateバックエンド設定
│   ├── variables.tf            # 変数定義
│   ├── outputs.tf              # デプロイ後のエンドポイントURL等を出力
│   ├── terraform.tfvars        # 変数値（.gitignore対象）
│   ├── modules/
│   │   ├── app_service/        # App Service Plan + Web App
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
│       └── create_index.py     # インデックス初期作成スクリプト
│
└── README.md
```

---

## Azure AI Search インデックススキーマ

```json
{
  "fields": [
    { "name": "id",            "type": "Edm.String",             "key": true },
    { "name": "chunk_text",    "type": "Edm.String",             "searchable": true },
    { "name": "vector",        "type": "Collection(Edm.Single)", "dimensions": 1536 },
    { "name": "company_name",  "type": "Edm.String",             "filterable": true, "facetable": true },
    { "name": "ticker",        "type": "Edm.String",             "filterable": true },
    { "name": "fiscal_year",   "type": "Edm.String",             "filterable": true, "facetable": true },
    { "name": "doc_type",      "type": "Edm.String",             "filterable": true },
    { "name": "section",       "type": "Edm.String",             "filterable": true },
    { "name": "page_number",   "type": "Edm.Int32",              "filterable": true },
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

cd app
pip install -r requirements.txt
streamlit run app.py
```

アプリは `http://localhost:8501` で起動します。

### インデックス初期構築

```bash
# Azure AI Searchインデックスを作成
python infra/scripts/create_index.py

# 企業リストを指定してIR資料を取得・インデックス投入
cd indexer
pip install -r ../app/requirements.txt
python main.py --tickers 7203,9984,6758
```

---

## Azure へのデプロイ

### 1. Terraformでインフラを作成

```bash
cd infra
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### 2. アプリをデプロイ

```bash
cd app
az webapp up \
  --name ir-rag-app \
  --resource-group ir-rag-rg \
  --runtime "PYTHON:3.11" \
  --sku B2
```

### 3. 環境変数をApp Serviceに設定

```bash
az webapp config appsettings set \
  --name ir-rag-app \
  --resource-group ir-rag-rg \
  --settings \
    AZURE_OPENAI_ENDPOINT="https://<your-resource>.openai.azure.com" \
    AZURE_OPENAI_API_KEY="<your-key>" \
    AZURE_SEARCH_ENDPOINT="https://<your-resource>.search.windows.net" \
    AZURE_SEARCH_API_KEY="<your-key>" \
    SQL_SERVER="<your-server>.database.windows.net" \
    SQL_DATABASE="ir_rag_db" \
    SQL_USERNAME="<your-username>" \
    SQL_PASSWORD="<your-password>" \
    AZURE_STORAGE_CONNECTION_STRING="<your-connection-string>" \
    EDINET_API_KEY="<your-key>"
```

### 4. インデックス初期構築

```bash
python infra/scripts/create_index.py
python indexer/main.py --tickers 7203,9984,6758
```

---

## 開発ロードマップ

- [ ] システム設計・アーキテクチャ確定
- [ ] Azure AI Searchインデックス構築
- [ ] EDINET PDF取得・チャンキングパイプライン
- [ ] LangGraph RAGパイプライン実装
- [ ] Streamlit UI実装
- [ ] App Serviceデプロイ
- [ ] RAGASによる精度評価・チューニング
- [ ] WebJobsによる定期更新バッチ設定

---

## ライセンス

MIT License
