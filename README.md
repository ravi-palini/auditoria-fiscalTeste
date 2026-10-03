# Auditoria Fiscal Kit

A comprehensive tax audit automation system for processing Brazilian NF-e (Nota Fiscal Eletrônica) XML files. The system identifies clients, compares invoice items against fiscal rules, and generates audit findings for human review.

## Overview

This kit automates the initial phase of tax audits by:
- Receiving and processing XML NF-e files
- Identifying the client associated with each document
- Comparing each item against pre-defined fiscal rules (hardcoded, not AI-guessed)
- Recording findings with estimated values
- Preparing everything for human review
- Using AI only to draft alert text and suggest treatments for NCMs without existing rules

## Project Structure

```
.
├── .claude/                  # Claude Code configuration
├── .git/                     # Git repository
├── .env                      # Environment variables
├── .gitignore                # Git ignore rules
├── LEIA-ME.md                # Documentation in Portuguese (this file)
├── README.md                 # This file (English documentation)
├── 01_banco.sql              # Database initialization script
├── 02_regras_iniciais.sql    # Initial fiscal rules
├── backup.sh                 # Backup utility
├── cliente_novo.sh           # Client management script
├── config.sh                 # Configuration utility
├── docker-compose.yml        # Docker Compose configuration
├── enviar_xmls.sh            # XML processing script
├── gerar_chave_secreta.sh    # Secret key generator
├── importar_regras.sh        # Rules import utility
├── iniciar_gui.sh            # GUI launcher
├── iniciar_metabase.sh       # Metabase (BI) launcher
├── instalar.sh               # Installation script
├── modelo_regras.csv         # Rules import template
├── relatorio.sh              # Reporting script
├── revisar.sh                # Review recording script
└── workflow_auditoria_fiscal.json  # n8n workflow definition
```

## Installation (~20 minutes)

1. Make scripts executable:
   ```bash
   chmod +x *.sh
   ```

2. Run the installation script:
   ```bash
   ./instalar.sh
   ```
   - Creates database tables
   - Loads 12 initial fiscal rules
   - Clears old test data

3. Register your first client:
   ```bash
   ./cliente_novo.sh 12345678000190 "Client Name" SIMPLES COMERCIO
   ```
   - Regime: SIMPLES, PRESUMIDO, or REAL
   - Activity: COMERCIO, INDUSTRIA, or IMPORTADOR

4. Deploy the n8n workflow:
   - In n8n: Deactivate/delete old workflow
   - Menu: `⋯ > Import from file` → Select `workflow_auditoria_fiscal.json`
   - Open Postgres and Gemini nodes, confirm credentials are selected
   - Click **Active** to activate the workflow

5. Process XML files:
   ```bash
   ./enviar_xmls.sh ./path/to/xml/files/
   ```
   - Processes all XML files in the specified directory

6. Launch Metabase for analytics:
   ```bash
   ./iniciar_metabase.sh
   ```
   - Access at: http://localhost:3000
   - When adding database:
     - Host: `host.docker.internal`
     - Port: `5432`
     - Database: `tax_automation_db`
   - Create questions based on views `v_achados` and `v_resumo_cliente`

## Daily Usage

| Action | Command |
|--------|---------|
| Register/update client | `./cliente_novo.sh CNPJ "Name" REGIME ACTIVITY` |
| Send XMLs for processing | `./enviar_xmls.sh ./directory` |
| Record reviewer decision | Form in n8n (Form Review node) or `./revisar.sh "12,13" APPROVED "Name" "notes"` |
| Generate client report (CSV) | `./relatorio.sh CNPJ > client.csv` (optional `so_aprovados` parameter) |
| Bulk load rules | `./importar_regras.sh rules.csv` (template in `modelo_regras.csv`) |
| Create backup | `./backup.sh` |

## Types of Findings

- `POSSIVEL_PAGAMENTO_INDEVIDO`: CST indicates "no taxation" but PIS/COFINS values are present
- `DIVERGENTE_REGRA`: NCM rule (zero rate/monophasic) doesn't match highlighted values
- `TESE_ICMS_BASE`: Presumed/Real regime client with ICMS still in PIS/COFINS basis (STF thesis, Theme 69)
- `OPORTUNIDADE_SIMPLES`: Simple regime client with monophasic/zero-rate/ICMS-ST product revenue (CSOSN 500)
- `CALCULO_DIVERGENTE`, `INCONSISTENCIA`: Internal invoice calculation errors
- `SEM_REGRA`: NCM without rule (goes to `sugestao_regra_ia` queue; IA suggests treatment nightly)
- `FORA_ESCOPO`: Client purchase note (credit analysis not yet implemented)

## Important Considerations Before Presenting Values

1. **Initial rules are NOT validated** (`validada = FALSE`) and were AI-generated. An accountant/tributarist must validate each rule (position vs. subitem, exceptions, validity, legal basis). After validation: `UPDATE regra_fiscal SET validada = TRUE WHERE id = ...;`
   Until then, each finding warns "rule still NOT validated".

2. **Rule 0808 legal basis needs verification.** Previous flow cited Law 10.925/2004; hortifrúti zero rate often cited in Law 10.865/2004, art. 28.

3. **Values are gross estimates.** Does not consider interest (Selic), compensation, exact prescription (5-year period; `prescricao_estimada` column is approximate by emission date) or if company already excludes ICMS in calculation (SPED).

4. **Homologation notes** are marked (`homologacao = true`) and excluded from reports.

5. **Treat XMLs as sensitive client data:** Use confidentiality/LGPD agreements and restrict machine access.

## Minimum Security

- Change the `secretpassword` and do not expose ports 5432 (Postgres) and 5678 (n8n) to the internet.
- Run `./backup.sh` before importing rules and weekly.

## Future Planned Features

- Purchase note analysis (tax credits)
- Own ICMS/IPI
- Reading new IBS/CBS fields from tax reform
- NFC-e/CT-e/NFS-e support
- Authentication/multi-user in review interface

## Troubleshooting

If a note produces an error, check the **Executions** tab in n8n. Expected messages:
- "No CNPJ from this note is registered as client" (register the client)
- "NF-e not authorized" (canceled/denied note is intentionally ignored)

---

**Note**: See `LEIA-ME.md` for the original documentation in Portuguese.