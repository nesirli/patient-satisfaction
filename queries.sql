SELECT * 
FROM hcahps_data 
LIMIT 10;

SELECT * 
FROM hospital_beds 
LIMIT 10;

WITH hospital_beds_prep AS
(
SELECT  LPAD(CAST(provider_ccn as TEXT), 6, '0') AS provider_ccn,
		hospital_name,
		TO_DATE(fiscal_year_begin_date, 'MM/DD/YYYY') AS fiscal_year_begin_date,
		TO_DATE(fiscal_year_end_date, 'MM/DD/YYYY') AS fiscal_year_end_date,
		number_of_beds,
		ROW_NUMBER() OVER (PARTITION BY provider_ccn ORDER BY TO_DATE(fiscal_year_end_date, 'MM/DD/YYYY')) AS nth_row
FROM hospital_beds
)
SELECT provider_ccn, COUNT(*)
FROM hospital_beds_prep
WHERE nth_row = 1
GROUP BY provider_ccn
ORDER BY COUNT(*);

WITH hospital_beds_prep AS
(
SELECT  LPAD(CAST(provider_ccn as TEXT), 6, '0') AS provider_ccn,
		hospital_name,
		TO_DATE(fiscal_year_begin_date, 'MM/DD/YYYY') AS fiscal_year_begin_date,
		TO_DATE(fiscal_year_end_date, 'MM/DD/YYYY') AS fiscal_year_end_date,
		number_of_beds,
		ROW_NUMBER() OVER (PARTITION BY provider_ccn ORDER BY TO_DATE(fiscal_year_end_date, 'MM/DD/YYYY')) AS nth_row
FROM hospital_beds
)

SELECT LPAD(CAST(facility_id as TEXT), 6, '0') AS provider_ccn,
		TO_DATE(start_date, 'MM/DD/YYYY') AS start_date_converted,
		TO_DATE(end_date, 'MM/DD/YYYY') AS end_date_converted,
		hcahps.*,
		beds.number_of_beds,
		beds.fiscal_year_begin_date AS beds_start_report_period,
		beds.fiscal_year_end_date AS beds_end_report_period
FROM hcahps_data as hcahps
LEFT JOIN hospital_beds_prep AS beds
ON LPAD(CAST(facility_id as TEXT), 6, '0') = beds.provider_ccn
AND beds.nth_row = 1