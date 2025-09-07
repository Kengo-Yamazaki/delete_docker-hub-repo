# delete-docker-hub-repo

Docker Hub のリポジトリを **リポジトリ単位** または **タグ単位** で削除するためのスクリプトです。  
不要になったリポジトリや特定のタグを整理するのに使えます。  

⚠️ **注意:** 削除したリポジトリやタグは元に戻せません。利用時は十分にご注意ください。

---

## 使い方

### 1. クローン
```bash
git clone https://github.com/Kengo-Yamazaki/delete_docker-hub-repo.git 
```
### 2. ディレクトリに移動
```bash
cd delete_docker-hub-repo
```
### 3. 実行
```bash
./delete_docker-hub_repo.sh
```

## 依存ツール

### 1. curl : API呼び出し用
### 2. jq : JSONパース用（タグ一覧取得に利用）

###Devian系の場合
```bash
sudo apt update
sudo apt install -y curl jq
```

###Redhat系の場合
```bash
sudo dnf update
sudo dnf install -y curl jq
```

