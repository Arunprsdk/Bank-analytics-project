CREATE DATABASE BankingDB;
USE BankingDB;
SELECT DATABASE();
CREATE TABLE Transactions (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID VARCHAR(50),
    CustomerName VARCHAR(100),
    AccountNumber VARCHAR(50),
    TransactionDate DATE,
    TransactionType VARCHAR(10),   -- Credit or Debit
    Amount DECIMAL(18,2),
    Balance DECIMAL(18,2),
    Description VARCHAR(255),
    Branch VARCHAR(100),
    TransactionMethod VARCHAR(50),
    Currency VARCHAR(10),
    BankName VARCHAR(100)
);
SELECT * FROM transactions LIMIT 10;


/* GRAND TOTAL (in millions) */
SET @GrandTotal := (SELECT SUM(Amount)/1000000 FROM transactions);

/* 1. Total Credit Amount (in millions) + Grand Total */
SELECT 
    SUM(Amount)/1000000 AS TotalCreditAmount_Millions,
    @GrandTotal AS GrandTotal_Millions
FROM transactions
WHERE TransactionType = 'Credit';

/* 2. Total Debit Amount (in millions) + Grand Total */
SELECT 
    SUM(Amount)/1000000 AS TotalDebitAmount_Millions,
    @GrandTotal AS GrandTotal_Millions
FROM transactions
WHERE TransactionType = 'Debit';

/* 3. Credit to Debit Ratio (no grand total needed) */
SELECT 
    SUM(CASE WHEN TransactionType='Credit' THEN Amount END) /
    SUM(CASE WHEN TransactionType='Debit' THEN Amount END)
    AS CreditToDebitRatio
FROM transactions;

/* 4. Net Transaction Amount (in millions) + Grand Total */
SELECT 
    (SUM(CASE WHEN TransactionType='Credit' THEN Amount END) -
     SUM(CASE WHEN TransactionType='Debit' THEN Amount END)) / 1000000
    AS NetTransactionAmount_Millions,
    @GrandTotal AS GrandTotal_Millions
FROM transactions;

/* 5. Account Activity Ratio (no grand total needed) */
SELECT 
    CustomerID,
    COUNT(*) / MAX(Balance) AS AccountActivityRatio
FROM transactions
GROUP BY CustomerID;

/* 6A. Transactions Per Day (no grand total needed) */
SELECT 
    TransactionDate,
    COUNT(*) AS TransactionsPerDay
FROM transactions
GROUP BY TransactionDate;

/* 6B. Transactions Per Week (no grand total needed) */
SELECT 
    YEARWEEK(TransactionDate) AS Week,
    COUNT(*) AS TransactionsPerWeek
FROM transactions
GROUP BY Week;

/* 6C. Transactions Per Month (no grand total needed) */
SELECT 
    DATE_FORMAT(TransactionDate, '%Y-%m') AS Month,
    COUNT(*) AS TransactionsPerMonth
FROM transactions
GROUP BY Month;

/* 7. Total Transaction Amount by Branch (in millions) + Grand Total */
SELECT 
    Branch,
    SUM(Amount)/1000000 AS TotalTransactionAmount_Millions,
    @GrandTotal AS GrandTotal_Millions
FROM transactions
GROUP BY Branch;

/* 8. Transaction Volume by Bank (no grand total needed) */
SELECT 
    BankName,
    COUNT(*) AS TransactionVolume
FROM transactions
GROUP BY BankName;

/* 9. Transaction Method Distribution (no grand total needed) */
SELECT 
    TransactionMethod,
    COUNT(*) AS MethodCount,
    CONCAT(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transactions)), 2), '%') 
        AS PercentageShare
FROM transactions
GROUP BY TransactionMethod;


/* 10. Branch Transaction Growth (no grand total needed) */
SELECT 
    Branch,
    DATE_FORMAT(TransactionDate, '%Y-%m') AS Month,
    SUM(Amount) AS TotalAmount,
    LAG(SUM(Amount)) OVER (PARTITION BY Branch ORDER BY DATE_FORMAT(TransactionDate, '%Y-%m')) AS PreviousMonth,
    ROUND(
        (
            (SUM(Amount) - LAG(SUM(Amount)) OVER (PARTITION BY Branch ORDER BY DATE_FORMAT(TransactionDate, '%Y-%m')))
            /
            LAG(SUM(Amount)) OVER (PARTITION BY Branch ORDER BY DATE_FORMAT(TransactionDate, '%Y-%m'))
        ) * 100, 
        2
    ) AS GrowthPercentage
FROM transactions
GROUP BY Branch, Month;


/* 11. High-Risk Transaction Flag (no grand total needed) */
SELECT 
    *,
    CASE WHEN Amount > 50000 THEN 'High-Risk' ELSE 'Normal' END AS RiskFlags
FROM transactions;

/* 12. Suspicious Transaction Frequency (no grand total needed) */
SELECT 
    COUNT(*) AS SuspiciousTransactionCount
FROM transactions
WHERE Amount > 50000;
