# Premier League 2025/26 Season Analysis

SQL-based analysis of the full 2025/26 Premier League season (380 matches, all 20 teams), covering attacking output, defensive record, win rates, discipline, and match officiating.

## Overview

This project explores team and match performance using match-level data sourced from football-data.co.uk. Data was cleaned and structured in Excel, loaded into a MySQL database, and analyzed using SQL — including aggregation, `CASE WHEN` logic, subqueries, and `UNION ALL` to combine home/away perspectives. Results were visualized in Excel.

## Questions Answered

1. Which team scored the most home goals?
2. Which team scored the most away goals?
3. Which team has the best away win rate?
4. Which team has the best overall win rate (home + away combined)?
5. Which team scored the most goals overall?
6. Which team conceded the fewest goals (best defense)?
7. Which referee officiated the most matches?
8. Which team received the most disciplinary cards (yellow + red)?

## Key Findings

- **Man City** led attacking output across the board — most home goals (45), most away goals (32), and most goals overall (77).
- **Arsenal** had the best overall win rate (68.4%) *and* the league's best defense (27 goals conceded) — suggesting a season built on consistency rather than raw firepower.
- **Tottenham** received the most disciplinary cards (104 total).
- **A Taylor** officiated the most matches (31) of any referee this season.

## Tools Used

- **MySQL** — data storage, querying, and analysis
- **Excel** — data cleaning, visualization

## Files

- `PL_analysis_queries.sql` — all 8 SQL queries used in this analysis

## Links

- [Full write-up and charts (LinkedIn post)](https://lnkd.in/p/eCUbUmC7)
