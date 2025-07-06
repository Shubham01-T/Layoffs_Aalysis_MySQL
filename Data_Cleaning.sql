USE layoffs;
SELECT * FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Date
-- 3. Null Values or Blank values
-- 4. Remove Any Columns which are NOT necessary

CREATE TABLE layoffs_staging
LIKE layoffs;

insert layoffs_staging
select * 
from layoffs;

WITH duplicate_cte AS(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company,location, stage, country,industry,percentage_laid_off, funds_raised_millions, industry, total_laid_off,
 `date`,stage,country,funds_raised_millions) AS ROW_NUM
 FROM layoffs_staging)

SELECT * FROM duplicate_cte
WHERE ROW_NUM > 1;

-- CREATING A NEW TABLE FOR DELETING DUPLICATE ENTRIES
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
  
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- SAVING THE PREVIOUS DATA + THE ROW_NUMBER IN THE NEW TABLE


INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company,location, stage, country,industry,percentage_laid_off, funds_raised_millions, industry, total_laid_off,
 `date`,stage,country,funds_raised_millions) AS ROW_NUM
 FROM layoffs_staging;
SELECT * FROM layoffs_stagiNg2
WHERE ROW_NUM>1;

-- DELETING DUPLICATE ROWS

DELETE
FROM layoffs_stagiNg2
WHERE ROW_NUM>1;

-- FIRST STEP COMPLETE! 

-- Step 2. Standardizing the Data

SELECT DISTINCT(TRIM(company))
FROM layoffs_staging2;

-- TRIMMING THE COMPANY NAME

UPDATE layoffs_staging2
SET company = TRIM(company); 

SELECT DISTINCT INDUSTRY FROM layoffs_staging2
ORDER BY 1;  -- WE NOTICE THAT THERE ARE 3 DIFFERENT INDUSTRIES FOR CRYPTO; WHICH NEEDS TO BE GROUPED TOGETHER // 

SELECT * FROM layoffs_staging2
WHERE INDUSTRY LIKE 'crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE INDUSTRY LIKE 'crypto%';

-- CHECKING LOCCATION COLUMN
SELECT DISTINCT(LOCATION) FROM layoffs_staging2
ORDER BY 1;
-- COUNTRY
SELECT DISTINCT(COUNTRY) FROM layoffs_staging2
ORDER BY 1;  -- There is a problem; The data has two United states one with a period at the end

SELECT * FROM layoffs_staging2
WHERE COUNTRY LIKE 'UNITED STATES%'
ORDER BY 1; 

UPDATE 
layoffs_staging2
SET COUNTRY = 'United States'
WHERE country like 'United States%';

-- Currently the `date` column is in 'Text' format; 
-- We need to change it to time series in order to perform future data analysis steps.

SELECT `date` ,
str_to_date(`date`,'%m/%d/%Y') 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`,'%m/%d/%Y');

SELECT `date` 
FROM layoffs_staging2
ORDER BY 1;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; -- CHAGED DATA TYPE TO DATE 
-- Dealing with some NULL values

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';  -- Some of the data can actully be populated manually

SELECT t1.industry, t2.industry FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2. company
WHERE (t1.industry IS NULL or t1.industry='' )
AND t2.industry IS NOT NULL;


UPDATE layoffs_staging2
SET industry = NULL
WHERE industry='';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2. company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL or t1.industry='' )
AND t2.industry IS NOT NULL;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- DROPPING THE UNNECESSARY COLUMNS 

ALTER TABLE
layoffs_staging2
DROP COLUMN row_num; 

SELECT * FROM layoffs_staging2  -- final cleaned data!!





