----------------------------------------------------------------------------------------------------------------------------------
-- QUERIES -----------------------------------------------------------------------------------------------------------------------

-- Deliverable#1 --------------------------------------------------------------------------------------------------------------------------
-- 	Section#1- Create a new table of eligible retirees currently working
-- 	Filter the "employees" to only those eligible to retire and exported to a new table
SELECT employees.first_name, employees.last_name
INTO retirement_info
FROM employees
LEFT JOIN titles
ON employees.emp_no = titles.emp_no
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- 	Check the table
SELECT * FROM retirement_info;

-- 	Creates a new table containing only the current employees who are eligible for retirement grouped by title
-- 	Using (3) joins to add the department info, titles and salaries
SELECT retirement_info.emp_no,
	retirement_info.first_name,
	retirement_info.last_name,
	titles.title,
	titles.from_date,
	salaries.salary
	
INTO current_eligible_emp

FROM retirement_info
LEFT JOIN dept_emp
ON retirement_info.emp_no = dept_emp.emp_no 
LEFT JOIN titles
ON dept_emp.emp_no = titles.emp_no 
LEFT JOIN salaries
ON titles.emp_no = salaries.emp_no 

WHERE dept_emp.to_date = ('9999-01-01')

ORDER BY retirement_info.emp_no;

----------------------------------------------------------------


-- Deliverable#1 
-- 	Section#2- Number of Retiring Employees by Title
-- 	There are duplicates because some employees have switched titles over the years. THese need to be addressed 
SELECT * FROM current_eligible_emp;


-- Deliverable#1 
-- 	Section#3- A new table that includes only the most recent title of each employee. 
-- 	Duplicates will be removed
-- 2nd table needed for the the Technical Analysis Report
SELECT	*
INTO retirement_eligible
From (SELECT current_eligible_emp.emp_no,
		current_eligible_emp.first_name,
		current_eligible_emp.last_name,
		current_eligible_emp.title,
		current_eligible_emp.from_date,
		current_eligible_emp.salary, ROW_NUMBER() OVER
 		(PARTITION BY (current_eligible_emp.emp_no)
 		ORDER BY current_eligible_emp.from_date DESC) rn
 		FROM current_eligible_emp
	 	) tmp WHERE rn = 1

ALTER TABLE retirement_eligible
DROP COLUMN rn;

SELECT * FROM retirement_eligible;
-------------------------------------------------------------------------
-- Number of employees with each title
-- 1st table needed for the the Technical Analysis Report
SELECT retirement_eligible.title, COUNT(retirement_eligible.emp_no)
INTO retiree_titles
FROM retirement_eligible
GROUP BY retirement_eligible.title

SELECT * FROM retiree_titles;
-------------------------------------------------------------------------
-- List of current employees born between Jan. 1, 1952 and Dec. 31, 1955
-- 3rd table needed for the the Technical Analysis Report
SELECT employees.first_name, employees.last_name
INTO empFrom_retirement_years
FROM employees
LEFT JOIN dept_emp
ON employees.emp_no = dept_emp.emp_no 
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (dept_emp.to_date = ('9999-01-01'));

-- 	Check the table
SELECT * FROM empFrom_retirement_years;

-- END DELIVERABLE #1 --------------------------------------------------------------------------------------------------------------------------  


-- Deliverable 2 -------------------------------------------------------------------------------------------------------------------------------
-- Mentorship Eligibility 
-- 	Needs: Employee number, First name, last name, Title, from_date, to_date
-- 	Birthday falls between January 1, 1965 and December 31, 1965

-- Query creates the base data but has the duplicates due to multiple titles.
SELECT employees.emp_no, employees.first_name, employees.last_name, titles.title, titles.from_date, titles.to_date
INTO mentorship_eligible_raw
FROM employees
LEFT JOIN titles
ON employees.emp_no = titles.emp_no
WHERE (birth_date BETWEEN '1965-01-01' AND '1965-12-31');
-- 	Check the table
SELECT * FROM mentorship_eligible_raw;
--DROP TABLE IF EXISTS mentorship_eligible;

-- Query to clear duplicates
SELECT	*
INTO mentorship_eligible
From (SELECT mentorship_eligible_raw.emp_no,
		mentorship_eligible_raw.first_name,
		mentorship_eligible_raw.last_name,
		mentorship_eligible_raw.title,
		mentorship_eligible_raw.from_date,
		mentorship_eligible_raw.to_date, ROW_NUMBER() OVER
 		(PARTITION BY (mentorship_eligible_raw.emp_no)
 		ORDER BY mentorship_eligible_raw.from_date DESC) rn
 		FROM mentorship_eligible_raw
	 	) tmp WHERE rn = 1

ALTER TABLE mentorship_eligible
DROP COLUMN rn;

SELECT * FROM mentorship_eligible;
