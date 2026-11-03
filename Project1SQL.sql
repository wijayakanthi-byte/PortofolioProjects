use PortifolioProject;
go

SELECT
    COUNT(*) AS total_transactions
FROM dbo.credit_card_fraud_detection;

--- 1. Cek Kualitas data
--memeriksa jumlah transaksi, ID unik, missing values, dan nilai transaksi.
SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT transaction_id)
        AS unique_transactions,

    SUM(
        CASE
            WHEN transaction_id IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_transaction_id,

    SUM(
        CASE
            WHEN customer_id IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_customer_id,

    SUM(
        CASE
            WHEN transaction_datetime IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_datetime,

    SUM(
        CASE
            WHEN transaction_amount IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_amount,

    SUM(
        CASE
            WHEN is_fraud IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_fraud_label

FROM dbo.credit_card_fraud_detection;

--- 2 Cek Duplikat tra
SELECT
    transaction_id,
    COUNT(*) AS duplicate_count

FROM dbo.credit_card_fraud_detection

GROUP BY transaction_id

HAVING COUNT(*) > 1;

--- 3.Fraud Overview #mulai analisis
SELECT

    COUNT(*) AS total_transactions,

    COUNT(DISTINCT customer_id)
        AS total_customers,

    COUNT(DISTINCT card_id)
        AS total_cards,

    COUNT(DISTINCT merchant_id)
        AS total_merchants,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN 1 ELSE 0
        END
    ) AS fraud_transactions,

    SUM(
        CASE
            WHEN is_fraud = 0
            THEN 1 ELSE 0
        END
    ) AS legitimate_transactions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN is_fraud = 1
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)

        AS DECIMAL(10,2)

    ) AS fraud_rate_pct,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN fraud_amount_lost
            ELSE 0
        END
    ) AS total_fraud_loss,

    AVG(
        CASE
            WHEN is_fraud = 1
            THEN transaction_amount
        END
    ) AS avg_fraud_transaction_amount

FROM dbo.credit_card_fraud_detection;

---6. Analisis Berdasarkan Waktu
--A. Fraud Berdasarkan Jam
SELECT

    transaction_hour,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN 1 ELSE 0
        END
    ) AS fraud_transactions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN is_fraud = 1
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)

        AS DECIMAL(10,2)

    ) AS fraud_rate_pct

FROM dbo.credit_card_fraud_detection

GROUP BY transaction_hour

ORDER BY transaction_hour;

--B.Fraud Berdasarkan Hari
SELECT

    transaction_day_of_week,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN 1 ELSE 0
        END
    ) AS fraud_transactions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN is_fraud = 1
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)

        AS DECIMAL(10,2)

    ) AS fraud_rate_pct

FROM dbo.credit_card_fraud_detection

GROUP BY transaction_day_of_week

ORDER BY transaction_day_of_week;

---6. Analisis merchant category
SELECT

    merchant_category,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN 1 ELSE 0
        END
    ) AS fraud_transactions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN is_fraud = 1
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)

        AS DECIMAL(10,2)

    ) AS fraud_rate_pct,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN fraud_amount_lost
            ELSE 0
        END
    ) AS fraud_loss

FROM dbo.credit_card_fraud_detection

GROUP BY merchant_category

ORDER BY fraud_rate_pct DESC;

---7. Analisis transaction channel
SELECT

    transaction_channel,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN 1 ELSE 0
        END
    ) AS fraud_transactions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN is_fraud = 1
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)

        AS DECIMAL(10,2)

    ) AS fraud_rate_pct,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN fraud_amount_lost
            ELSE 0
        END
    ) AS fraud_loss

FROM dbo.credit_card_fraud_detection

GROUP BY transaction_channel

ORDER BY fraud_rate_pct DESC;

--- 8. Risk indicators
--A. International transaction
SELECT

    international_transaction,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN 1 ELSE 0
        END
    ) AS fraud_transactions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN is_fraud = 1
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)

        AS DECIMAL(10,2)

    ) AS fraud_rate_pct

FROM dbo.credit_card_fraud_detection

GROUP BY international_transaction;

--B. Amount vs average transaction
SELECT

    CASE

        WHEN amount_vs_avg_ratio <= 1
            THEN 'Normal'

        WHEN amount_vs_avg_ratio <= 2
            THEN 'Above Average'

        WHEN amount_vs_avg_ratio <= 3
            THEN 'High Amount'

        ELSE 'Very High Amount'

    END AS amount_segment,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN 1 ELSE 0
        END
    ) AS fraud_transactions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN is_fraud = 1
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)

        AS DECIMAL(10,2)

    ) AS fraud_rate_pct

FROM dbo.credit_card_fraud_detection

GROUP BY

    CASE

        WHEN amount_vs_avg_ratio <= 1
            THEN 'Normal'

        WHEN amount_vs_avg_ratio <= 2
            THEN 'Above Average'

        WHEN amount_vs_avg_ratio <= 3
            THEN 'High Amount'

        ELSE 'Very High Amount'

    END

ORDER BY fraud_rate_pct DESC;