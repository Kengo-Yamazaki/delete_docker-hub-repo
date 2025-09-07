#!/bin/bash

# ------------------------------
# Docker Hub リポジトリ削除スクリプト（タグ単位オプション付き）
# ------------------------------

# ユーザーに Docker Hub のユーザー名を入力させる
read -p "DOCKERHUB_USERNAME= " DOCKERHUB_USERNAME
if [[ -z "$DOCKERHUB_USERNAME" ]]; then
	    echo "ユーザー名が入力されませんでした。"
	        exit 1
fi

# ユーザーに Docker Hub のパスワードを入力させる（非表示）
read -s -p "DOCKERHUB_PASSWORD= " DOCKERHUB_PASSWORD
echo
if [[ -z "$DOCKERHUB_PASSWORD" ]]; then
	    echo "パスワードが入力されませんでした。"
	        exit 1
fi

# ユーザーに削除対象のリポジトリ名を入力させる
read -p "削除対象のリポジトリ名= " REPO_NAME
if [[ -z "$REPO_NAME" ]]; then
	    echo "リポジトリ名が入力されませんでした。"
	        exit 1
fi

# JWT トークン取得
TOKEN=$(curl -s -H "Content-Type: application/json" \
	    -X POST \
	        -d "{\"username\": \"$DOCKERHUB_USERNAME\", \"password\": \"$DOCKERHUB_PASSWORD\"}" \
		    https://hub.docker.com/v2/users/login/ | jq -r .token)

if [[ "$TOKEN" == "null" || -z "$TOKEN" ]]; then
	    echo "ログインに失敗しました。ユーザー名・パスワードを確認してください。"
	        exit 1
fi

# 削除方法選択
echo "削除方法を選択してください："
echo "1) リポジトリ全体を削除"
echo "2) 特定のタグのみ削除"
read -p "選択 (1 or 2): " choice

if [[ "$choice" == "1" ]]; then
	    # 確認プロンプト
	        read -p "本当に Docker Hub 上のリポジトリ '$DOCKERHUB_USERNAME/$REPO_NAME' を削除しますか？ [y/N]: " confirm
		    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
			            echo "キャンセルしました。"
				            exit 0
					        fi

						    # リポジトリ削除
						        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
								        -H "Authorization: JWT $TOKEN" \
									        -X DELETE \
										        https://hub.docker.com/v2/repositories/$DOCKERHUB_USERNAME/$REPO_NAME/)

							    if [[ "$HTTP_STATUS" == "204" ]]; then
								            echo "リポジトリ '$DOCKERHUB_USERNAME/$REPO_NAME' を削除しました。"
									        else
											        echo "削除に失敗しました。HTTPステータス: $HTTP_STATUS"
												    fi

											    elif [[ "$choice" == "2" ]]; then
												        # タグ一覧取得
													    TAGS=$(curl -s -H "Authorization: JWT $TOKEN" \
														            https://hub.docker.com/v2/repositories/$DOCKERHUB_USERNAME/$REPO_NAME/tags/?page_size=100 | jq -r '.results[].name')

													        if [[ -z "$TAGS" ]]; then
															        echo "タグが見つかりません。リポジトリ名を確認してください。"
																        exit 1
																	    fi

																	        echo "削除可能なタグ一覧："
																		    echo "$TAGS"
																		        read -p "削除したいタグを入力してください（複数ある場合はカンマ区切り）: " TAG_INPUT

																			    # 確認プロンプト
																			        read -p "本当に以下のタグを削除しますか？ [$TAG_INPUT] [y/N]: " confirm
																				    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
																					            echo "キャンセルしました。"
																						            exit 0
																							        fi

																								    # タグ削除ループ
																								        IFS=',' read -ra TAG_ARRAY <<< "$TAG_INPUT"
																									    for tag in "${TAG_ARRAY[@]}"; do
																										            tag_trimmed=$(echo "$tag" | xargs) # 前後の空白削除
																											            HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
																													                -H "Authorization: JWT $TOKEN" \
																															            -X DELETE \
																																                https://hub.docker.com/v2/repositories/$DOCKERHUB_USERNAME/$REPO_NAME/tags/$tag_trimmed/)

																												            if [[ "$HTTP_STATUS" == "204" ]]; then
																														                echo "タグ '$tag_trimmed' を削除しました。"
																																        else
																																		            echo "タグ '$tag_trimmed' の削除に失敗しました。HTTPステータス: $HTTP_STATUS"
																																			            fi
																																				        done
																																				else
																																					    echo "無効な選択です。スクリプトを終了します。"
																																					        exit 1
fi

