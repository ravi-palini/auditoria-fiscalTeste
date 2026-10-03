# Auditoria Fiscal – kit para o primeiro cliente

O que o sistema faz: recebe XMLs de NF-e, identifica o cliente, compara cada item com regras (em código, não "no palpite da IA"),
grava os achados com valor estimado e deixa tudo pronto para revisão humana. A IA só redige o texto do alerta e sugere
tratamento para NCMs que ainda não têm regra.

## Instalação (uma vez, ~20 minutos)

Abra o terminal **dentro desta pasta** e rode:

1. `chmod +x *.sh`
2. `./instalar.sh` – cria as tabelas, carrega 12 regras iniciais e apaga as linhas de teste antigas.
3. `./cliente_novo.sh 12345678000190 "Nome do Cliente" SIMPLES COMERCIO`
   (regime: SIMPLES, PRESUMIDO ou REAL; atividade: COMERCIO, INDUSTRIA ou IMPORTADOR)
4. No n8n: desative (ou apague) o workflow antigo, menu **⋯ > Import from file** e escolha `workflow_auditoria_fiscal.json`.
   Abra os nós Postgres e Gemini e confirme que a credencial aparece selecionada. Depois ligue o botão **Active**.
5. `./enviar_xmls.sh ./pasta_com_xmls` – envia todos os XMLs da pasta.
6. `./iniciar_metabase.sh` – painel em http://localhost:3000. Ao adicionar o banco use host `host.docker.internal`,
   porta 5432, banco `tax_automation_db`. Crie perguntas em cima das views `v_achados` e `v_resumo_cliente`.

## Uso no dia a dia

| Quero… | Comando |
|---|---|
| Cadastrar/atualizar cliente | `./cliente_novo.sh CNPJ "Nome" REGIME ATIVIDADE` |
| Enviar notas | `./enviar_xmls.sh ./pasta` |
| Registrar decisão do revisor | formulário do n8n (nó "Formulário de Revisão", URL de produção) ou `./revisar.sh "12,13" APROVADO "Nome" "obs"` |
| Gerar relatório do cliente (CSV) | `./relatorio.sh CNPJ > cliente.csv` (opcional `so_aprovados`) |
| Carregar regras em massa | `./importar_regras.sh regras.csv` (modelo em `modelo_regras.csv`) |
| Backup | `./backup.sh` |

Se uma nota der erro, veja a aba **Executions** do n8n. Mensagens esperadas: "Nenhum CNPJ desta nota está cadastrado como cliente"
(cadastre o cliente) e "NF-e não autorizada" (nota cancelada/denegada é ignorada de propósito).

## Tipos de achado

- `POSSIVEL_PAGAMENTO_INDEVIDO`: CST diz "sem tributação", mas há valor de PIS/COFINS destacado.
- `DIVERGENTE_REGRA`: a regra do NCM (alíquota zero / monofásico) não bate com o que foi destacado.
- `TESE_ICMS_BASE`: cliente Presumido/Real com ICMS ainda dentro da base de PIS/COFINS (tese do STF, Tema 69).
- `OPORTUNIDADE_SIMPLES`: cliente do Simples com receita de produto monofásico/alíquota zero/ICMS-ST (CSOSN 500). É preciso conferir no PGDAS-D; o valor não é calculável só pelo XML.
- `CALCULO_DIVERGENTE`, `INCONSISTENCIA`: erros internos da própria nota.
- `SEM_REGRA`: NCM sem regra (vai para a fila `sugestao_regra_ia`; toda madrugada a IA sugere um tratamento para triagem).
- `FORA_ESCOPO`: nota de compra do cliente (análise de créditos ainda não existe).

## Antes de apresentar QUALQUER valor a um cliente

1. **As 12 regras iniciais NÃO estão validadas** (`validada = FALSE`) e foram escritas por IA. Um contador/tributarista precisa conferir cada uma
   (posição vs. subitem, exceções, vigência, base legal). Depois: `UPDATE regra_fiscal SET validada = TRUE WHERE id = ...;`
   Enquanto isso, o alerta de cada achado avisa "regra ainda NÃO validada".
2. **A base legal da regra 0808 precisa de conferência.** O fluxo antigo citava a Lei 10.925/2004; a alíquota zero de hortifrúti costuma ser citada na Lei 10.865/2004, art. 28.
3. **O valor é estimativa bruta.** Não considera juros (Selic), compensação, decadência exata (prazo de 5 anos; a coluna `prescricao_estimada` é aproximada pela data de emissão) nem se a empresa já exclui o ICMS na apuração (SPED).
4. Notas de **homologação** ficam marcadas (`homologacao = true`) e fora dos relatórios.
5. Trate os XMLs como dado sensível do cliente: contrato com cláusula de confidencialidade/LGPD e acesso restrito à máquina.

## Segurança mínima

- Troque a senha `secretpassword` e não exponha as portas 5432 (Postgres) e 5678 (n8n) na internet.
- Rode `./backup.sh` antes de importar regras e toda semana.

## Ainda não existe (próximas etapas)

Análise de notas de compra (créditos), ICMS próprio/IPI, leitura dos novos campos de IBS/CBS da reforma tributária,
NFC-e/CT-e/NFS-e e autenticação/multiusuário na interface de revisão.
