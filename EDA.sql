USE `layoffs`;

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;



SELECT MIN(`date`),MAX(`date`)
FROM layoffs_staging2; -- data we have ranges from march 2020 to march 2023

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY industry
ORDER BY 2 DESC;  -- consumer industry was the most affected industry; manafacturing was the least affected industry

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY company
ORDER BY 2 DESC; -- Amazon seems to have laid off highest number of people

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY country
ORDER BY 2 desc; -- USA has the highest number of layoffs at over 256,000; followed by India at approx 36,000

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY YEAR(`date`) 
order by 2 desc; -- year 2022 reported the highest number of layoffs; ALSO in the year 2023 it has been witnesssed that  125677 got laid off in just first three months

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2 
GROUP BY stage
order by 2 desc; -- over 200,000 laid off; Post-IPO eg. Amazon & Google

SELECT SUBSTRING(`date`,1,7) AS yearmonth, sum(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY yearmonth
ORDER BY 1;

WITH ROLLING_TOTAL AS 
(
SELECT SUBSTRING(`date`,1,7) AS yearmonth, sum(total_laid_off) AS Monthly
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY yearmonth
ORDER BY 1
)
SELECT `yearmonth`, Monthly, SUM(Monthly) OVER (ORDER BY `yearmonth`) AS  Rolling_total
FROM ROLLING_TOTAL;  -- Obtaining the rolling total wrt year-month

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY SUM(total_laid_off) DESC;

WITH Company_year (Company, Years, Total_laid_off) AS(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
),
Company_Ranking AS(
SELECT *, DENSE_RANK() OVER(PARTITION BY Years ORDER BY Total_laid_off DESC) AS Ranking
 FROM Company_year
 WHERE Years IS NOT NULL
 ORDER BY Ranking ASC)
 
 SELECT * FROM Company_Ranking
 WHERE Ranking <= 5;  -- TOP 5 COMPANIES EVERY YEAR












