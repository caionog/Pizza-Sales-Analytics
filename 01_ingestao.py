# ============================================================
# 01_ingestao.py
# Ingestão e tratamento do CSV pizza_sales para o SQL Server
#
# Responsabilidade: ler o CSV em inglês (en-US), corrigir os
# tipos de dados afetados pelo ambiente PT-BR e inserir os dados
# já limpos na tabela pizza_sales do SQL Server.
#
# Dependências:
#   pip install pandas pyodbc sqlalchemy
#
# Conexão: Windows Authentication (Trusted Connection)
# ============================================================

import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError


# ------------------------------------------------------------
# CONFIGURAÇÃO — ajuste SERVER e DATABASE para o seu ambiente
# ------------------------------------------------------------
SERVER   = 'NOME_DO_SEU_SERVIDOR'   # ex: 'localhost' ou 'DESKTOP-XXXX\SQLEXPRESS'
DATABASE = 'SalesDB'
CSV_PATH = 'raw/pizza_sales.csv'


# ------------------------------------------------------------
# PASSO 1 — Ler o CSV
# ------------------------------------------------------------
print('Lendo CSV...')

df = pd.read_csv(
    CSV_PATH,
    dtype={
        'pizza_id'        : 'int64',
        'order_id'        : 'int64',
        'pizza_name_id'   : 'str',
        'quantity'        : 'int64',
        'order_date'      : 'str',    # lido como texto para conversão manual
        'order_time'      : 'str',
        'unit_price'      : 'float64',
        'total_price'     : 'float64',
        'pizza_size'      : 'str',
        'pizza_category'  : 'str',
        'pizza_ingredients': 'str',
        'pizza_name'      : 'str',
    }
)

print(f'  {len(df)} registros carregados.')


# ------------------------------------------------------------
# PASSO 2 — Corrigir tipos afetados pelo ambiente PT-BR
# ------------------------------------------------------------
print('Convertendo tipos...')

# order_date: CSV usa DD-MM-YYYY (texto) → datetime
df['order_date'] = pd.to_datetime(df['order_date'], format='%d-%m-%Y').dt.date

# order_time: garantir formato HH:MM:SS como string
df['order_time'] = pd.to_datetime(df['order_time'], format='%H:%M:%S').dt.time

# Preços: arredondar para 2 casas decimais (evitar float impreciso)
df['unit_price']  = df['unit_price'].round(2)
df['total_price'] = df['total_price'].round(2)


# ------------------------------------------------------------
# PASSO 3 — Validações antes de inserir
# ------------------------------------------------------------
print('Validando dados...')

erros = []

if df.isnull().any().any():
    erros.append('Existem valores nulos no DataFrame.')

if df.duplicated(subset='pizza_id').any():
    erros.append('Existem pizza_id duplicados.')

inconsistentes = df[df['total_price'].round(2) != (df['unit_price'] * df['quantity']).round(2)]
if not inconsistentes.empty:
    erros.append(f'{len(inconsistentes)} registros com total_price inconsistente.')

if erros:
    for e in erros:
        print(f'  [ERRO] {e}')
    raise ValueError('Validação falhou. Corrija os erros antes de inserir.')

print('  Validações OK.')


# ------------------------------------------------------------
# PASSO 4 — Inserir no SQL Server
# ------------------------------------------------------------
print('Conectando ao SQL Server...')

connection_string = (
    f'mssql+pyodbc://@{SERVER}/{DATABASE}'
    f'?driver=ODBC+Driver+17+for+SQL+Server'
    f'&trusted_connection=yes'
)

engine = create_engine(connection_string, fast_executemany=True)

print('Inserindo dados...')

try:
    with engine.begin() as conn:
        # Limpa a tabela antes de reinserir (idempotente)
        conn.execute(text('TRUNCATE TABLE pizza_sales'))

        df.to_sql(
            name      = 'pizza_sales',
            con       = conn,
            if_exists = 'append',   # tabela já existe no SQL Server
            index     = False,
        )

    print(f'  {len(df)} registros inseridos com sucesso em pizza_sales.')

except SQLAlchemyError as e:
    print(f'  [ERRO] Falha ao inserir dados: {e}')
    raise
