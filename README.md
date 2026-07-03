# Pizza Sales Analytics
Projeto de Business Intelligence desenvolvido com Python, SQL Server e Power BI para análise de vendas de uma pizzaria.

O objetivo foi construir uma pipeline completa de dados, desde a ingestão do dataset bruto até a criação de uma camada analítica pronta para consumo no dashboard.

---

## Tecnologias Utilizadas

- Python
- Pandas
- SQL Server
- SQL
- Power BI
- CSV

---

## Arquitetura da Solução

CSV (Dados Brutos)
↓
Python (Limpeza e tratamento)
↓
SQL Server
↓
Validações de integridade
↓
View analítica
↓
Power BI
↓
Dashboard executivo

---

## Estrutura do Projeto

```
pizza-sales-analytics/

├── raw/
│   └── pizza_sales.csv
│
├── sql/
│   ├── 02_etl_integridade.sql
│   └── 03_view_analytics.sql
│
├── powerbi/
│   ├── Pizza_BI.pbip
│   └── Pizza_BI.pbix
│
├── 01_ingestao.py
├── .gitignore
└── README.md
```

---

## Dataset

O projeto utiliza um dataset de vendas de uma pizzaria contendo informações de:

- Pedidos
- Produtos vendidos
- Categorias de pizzas
- Tamanhos
- Quantidades
- Receita

Período analisado:

- Janeiro/2015 a Dezembro/2015

---

## Etapas do Projeto

### 1. Criação da Base
O script SQL de integridade cria a tabela `pizza_sales` no SQL Server caso ela ainda não exista.

Script disponível em:

```
sql/02_etl_integridade.sql
```

### 2. Ingestão, Limpeza e Tratamento
Os dados são lidos a partir do CSV bruto e tratados com Python antes da carga na base.

Principais atividades:

- Leitura do arquivo `raw/pizza_sales.csv`
- Conversão de tipos de data e hora
- Correção de arredondamentos em valores monetários
- Validações de nulidade, duplicidade e consistência de totais
- Inserção dos dados limpos no SQL Server

Script disponível em:

```
01_ingestao.py
```

### 3. Validações de Integridade
Após a carga, são executadas verificações para confirmar a qualidade e a consistência dos dados.

Principais checagens:

- Quantidade total de registros
- Verificação de campos nulos em colunas críticas
- Consistência entre `unit_price`, `quantity` e `total_price`
- Intervalo de datas esperado para o dataset

Script disponível em:

```
sql/02_etl_integridade.sql
```

### 4. Camada Analítica
Foi criada uma view analítica consolidando os campos necessários para consumo direto no Power BI.

Script disponível em:

```
sql/03_view_analytics.sql
```

### 5. Desenvolvimento do Dashboard
O dashboard foi desenvolvido no Power BI com conexão à view analítica criada no SQL Server.


---

## Report

### KPIs

O relatório foi desenhado para acompanhar indicadores-chave e suportar análises rápidas do negócio:

- Total Revenue
- Average Order Value
- Total Pizzas Sold
- Total Orders
- Average Pizzas Per Order

### Definição das Medidas

As seguintes medidas do dashboard foram criadas no Power BI com base na view analítica:

```DAX
Total Revenue = SUM(vw_pizza_sales_analytics[total_price])

Total Pizzas Sold = SUM(vw_pizza_sales_analytics[quantity])

Total Orders = DISTINCTCOUNT(vw_pizza_sales_analytics[order_id])

Average Order Value = [Total Revenue] / [Total Orders]

Average Pizzas Per Order = [Total Pizzas Sold] / [Total Orders]

Medium Quantity =
AVERAGEX(
	VALUES(vw_pizza_sales_analytics[pizza_name]),
	CALCULATE([Total Pizzas Sold])
)

Medium Revenue Per Pizza =
AVERAGEX(
	VALUES(vw_pizza_sales_analytics[pizza_name]),
	CALCULATE([Total Revenue])
)
```

### Gráficos Gerados

Para explorar o comportamento das vendas e facilitar a leitura executiva, o dashboard inclui:

1. Daily Trend for total orders
2. Monthly Trend for total orders
3. Percentage of Sales by pizza category
4. Percentage of sales by pizza size
5. Total Pizzas sold by pizza category
6. Top 5 sellers by revenue, total quantity and total orders
7. Bottom 5 sellers by revenue, total quantity and total orders
8. HeatMap Average Pizzas Sold
9. Scatter Plot Pizzas Sold by Revenue

---

## Reproduzindo o Projeto

1. Executar `sql/02_etl_integridade.sql` para criar a tabela.
2. Configurar `01_ingestao.py` com o servidor e o banco de dados corretos.
3. Executar `01_ingestao.py` para carregar e tratar os dados.
4. Executar novamente `sql/02_etl_integridade.sql` para validar a carga.
5. Executar `sql/03_view_analytics.sql` para criar a view analítica.
6. Abrir o arquivo `powerbi/Pizza_BI.pbix` no Power BI.
7. Atualizar a conexão com o banco local, se necessário.

---

## Documentação Completa

Este repositório concentra os artefatos principais do projeto técnico. Caso você publique a apresentação final em outro local, substitua o link abaixo pelo endereço correspondente:

[Portfólio / Case Study](LINK_DO_GITHUB_PAGES)