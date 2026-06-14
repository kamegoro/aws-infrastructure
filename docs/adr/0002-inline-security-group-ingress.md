# 0002. セキュリティグループのingressをインラインで定義する

## ステータス

承認

## 背景

`network`モジュールのECS用セキュリティグループ（`aws_security_group.ecs_service`）は、
ALB用セキュリティグループからのインバウンドのみを許可する。

当初これを別リソース`aws_security_group_rule`
（`source_security_group_id`でALBのSGを指定）として定義していたが、
MiniStackに対して`apply`すると、ルール自体は
`DescribeSecurityGroups`の`IpPermissions`には反映されるものの
`DescribeSecurityGroupRules`には現れず、Terraformの作成待ち(waiter)が
タイムアウトする問題があった
（[ministackorg/ministack#916](https://github.com/ministackorg/ministack/issues/916)）。

## 決定

セキュリティグループ間のingressルールは、`aws_security_group_rule`の
別リソースではなく、`aws_security_group`リソースの`ingress`ブロック内に
`security_groups = [aws_security_group.alb.id]`として直接記述する。

## 理由

- `aws_security_group_rule`の作成waiterが`DescribeSecurityGroupRules`を
  ポーリングするのに対し、インラインの`ingress`ブロックは
  `aws_security_group`本体（`DescribeSecurityGroups`）の作成・更新のみに
  依存するため、MiniStackでタイムアウトしない
- AWS上での実際の動作（許可されるトラフィック）は変わらない
- 別リソースに分割するほどの理由（他リソースからの動的な追加など）が
  現時点ではない

## 影響

- `aws_security_group_rule`は使用せず、SG間の参照は
  `aws_security_group`の`ingress`/`egress`ブロック内で直接行う
- 今後、動的にルールを追加する必要が出た場合は、改めて
  `aws_security_group_rule`への分割とMiniStackでの動作確認を検討する
