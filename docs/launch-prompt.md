# 启动提示词

规格、验收标准、流程和角色都已经写在仓库里，所以启动提示词很短。在项目根目录打开 agent，粘贴下面对应的一段。

## 首次启动

```text
按 AGENTS.md 开始工作：先读 docs/PROGRESS.md 和 docs/workflow.md，从第 1 步做起。

你将独立、长时间地工作，中途没有人回答问题。规格没覆盖的细节自己决定并记入 docs/PROGRESS.md；
只有 AGENTS.md“约束”里列出的情况才暂停。

完成需要三样同时成立：测试真实跑过且每条 AC 都有证据；独立验收者给出通过结论并存入
docs/review-record.md；tools/harness-check.ps1 -Stage final 通过。脚本只核对材料齐全一致，
不能代替前两样。没达到就继续修复和复验，不要以“基本完成”结束。
按 docs/workflow.md 把写测试、写实现、验收分给不同的子代理。
```

## 中断后恢复

```text
继续这个项目。先读 docs/PROGRESS.md（包括“短规则”），再按 docs/workflow.md 第 0 步核实工作区的
实际状态，然后从正确的位置接着做，不要从头重来。其余要求和完成标准同 AGENTS.md 和 docs/workflow.md。
```

## 工具不支持子代理时

把首次启动提示词的最后一句换成：

```text
这个环境没有子代理。按 docs/workflow.md 的顺序自己完成，但严格分阶段：
先写完测试并提交，再开始实现；实现阶段不修改测试和验收标准。
在 docs/acceptance-report.md 的说明列注明哪些条目是你自己复核的。
```

这种情况下，建议最后另开一个新会话，只让它扮演 `docs/roles/reviewer.md` 做一次验收。

## 说明

提示词不能让会话在结束后自己续跑。会话断了，用“中断后恢复”那一段重新开始即可，进度在 `docs/PROGRESS.md` 里。
