-- ============================================================
-- 1. DATABASE TABLE CREATION
-- ============================================================

-- ------------------------------------------------------------
-- Patients Table
-- ------------------------------------------------------------

CREATE TABLE patients (
    patient_id VARCHAR(10) PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    city VARCHAR(50),
    blood_group VARCHAR(5)
);


-- ------------------------------------------------------------
-- Doctors Table
-- ------------------------------------------------------------

CREATE TABLE doctors (
    doctor_id VARCHAR(10) PRIMARY KEY,
    doctor_name VARCHAR(100),
    department VARCHAR(50)
);


-- ------------------------------------------------------------
-- Admissions Table
-- ------------------------------------------------------------

CREATE TABLE admissions (
    admission_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10),
    admission_date DATE,
    discharge_date DATE,
    department VARCHAR(50),
    diagnosis VARCHAR(100),
    treatment VARCHAR(100),
    doctor_id VARCHAR(10),
    insurance_provider VARCHAR(100),
    admission_type VARCHAR(20),
    room_type VARCHAR(30),
    length_of_stay INT,
    medical_expenses NUMERIC(12, 2),
    insurance_coverage NUMERIC(12, 2),
    patient_satisfaction NUMERIC(2, 1),
    readmission VARCHAR(5),
    follow_up_required VARCHAR(5),

    CONSTRAINT fk_admission_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    CONSTRAINT fk_admission_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
);


-- ------------------------------------------------------------
-- Lab Tests Table
-- ------------------------------------------------------------

CREATE TABLE lab_tests (
    test_id VARCHAR(10) PRIMARY KEY,
    admission_id VARCHAR(10),
    patient_id VARCHAR(10),
    test_name VARCHAR(100),
    test_date DATE,
    test_result VARCHAR(20),
    test_cost NUMERIC(10, 2),

    CONSTRAINT fk_lab_admission
        FOREIGN KEY (admission_id)
        REFERENCES admissions(admission_id),

    CONSTRAINT fk_lab_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
);


-- ============================================================
-- BASIC LEVEL
-- ============================================================


-- ============================================================
-- Q1. Patients by Gender and Average Age
-- ============================================================
-- Find the number of patients by gender and calculate
-- the average age for each gender.
-- ============================================================

SELECT
    gender,
    COUNT(*) AS total_patients,
    ROUND(AVG(age), 2) AS average_age
FROM patients
GROUP BY gender
ORDER BY total_patients DESC;


-- ============================================================
-- Q2. Admissions and Average Length of Stay by Department
-- ============================================================
-- Find the total number of admissions and the average
-- length of stay for each department.
-- ============================================================

SELECT
    department,
    COUNT(*) AS total_admissions,
    ROUND(AVG(length_of_stay), 2) AS average_length_of_stay
FROM admissions
GROUP BY department
ORDER BY total_admissions DESC;


-- ============================================================
-- Q3. Admissions by Admission Type
-- ============================================================
-- Find the number and percentage of admissions for each
-- admission type: Emergency, Urgent, and Elective.
-- ============================================================

SELECT
    admission_type,
    COUNT(*) AS total_admissions,
    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_admissions
FROM admissions
GROUP BY admission_type
ORDER BY total_admissions DESC;


-- ============================================================
-- Q4. Departments with Average Medical Expense Above ₹30,000
-- ============================================================
-- Find departments where the average medical expense
-- per admission is greater than ₹30,000.
-- ============================================================

SELECT
    department,
    ROUND(AVG(medical_expenses), 2) AS average_medical_expense
FROM admissions
GROUP BY department
HAVING AVG(medical_expenses) > 30000
ORDER BY average_medical_expense DESC;


-- ============================================================
-- Q5. Monthly Admission Trend
-- ============================================================
-- Find the total number of admissions for each month.
-- ============================================================

SELECT
    DATE_TRUNC('month', admission_date) AS month,
    COUNT(*) AS total_admissions
FROM admissions
GROUP BY DATE_TRUNC('month', admission_date)
ORDER BY month;


-- ============================================================
-- INTERMEDIATE LEVEL
-- ============================================================


-- ============================================================
-- Q6. Admission Details with Patient and Doctor Information
-- ============================================================
-- Display each admission along with:
-- Patient ID, Age, Gender, Department, Diagnosis,
-- and Doctor Name.
-- ============================================================

SELECT
    a.admission_id,
    a.patient_id,
    p.age,
    p.gender,
    a.department,
    a.diagnosis,
    d.doctor_name
FROM admissions AS a
INNER JOIN patients AS p
    ON a.patient_id = p.patient_id
INNER JOIN doctors AS d
    ON a.doctor_id = d.doctor_id;


-- ============================================================
-- Q7. Top 5 Doctors by Number of Admissions
-- ============================================================
-- Find the top 5 doctors who handled the highest
-- number of hospital admissions.
-- ============================================================

SELECT
    d.doctor_name,
    COUNT(*) AS total_admissions
FROM admissions AS a
INNER JOIN doctors AS d
    ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_name
ORDER BY total_admissions DESC
LIMIT 5;


-- ============================================================
-- Q8. Insurance Provider Cost and Coverage Analysis
-- ============================================================
-- For each insurance provider, calculate:
-- 1. Total medical expenses
-- 2. Total insurance coverage
-- 3. Average insurance coverage
-- 4. Remaining patient expense
-- ============================================================

SELECT
    insurance_provider,
    ROUND(SUM(medical_expenses), 2) AS total_medical_expense,
    ROUND(SUM(insurance_coverage), 2) AS total_insurance_coverage,
    ROUND(AVG(insurance_coverage), 2) AS average_insurance_coverage,
    ROUND(
        SUM(medical_expenses) - SUM(insurance_coverage),
        2
    ) AS remaining_patient_expense
FROM admissions
GROUP BY insurance_provider
ORDER BY remaining_patient_expense DESC;


-- ============================================================
-- Q9. Readmission Rate by Department
-- ============================================================
-- Calculate the readmission rate for each department
-- and identify the department with the highest rate.
-- ============================================================

SELECT
    department,
    COUNT(*) AS total_admissions,
    COUNT(
        CASE
            WHEN readmission = 'Yes' THEN 1
        END
    ) AS total_readmissions,
    ROUND(
        COUNT(
            CASE
                WHEN readmission = 'Yes' THEN 1
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate
FROM admissions
GROUP BY department
ORDER BY readmission_rate DESC
LIMIT 1;


-- ============================================================
-- Q10. Top 5 Laboratory Tests by Total Cost
-- ============================================================
-- Find the top 5 laboratory tests based on total testing cost.
-- Show:
-- 1. Number of tests
-- 2. Total test cost
-- 3. Average test cost
-- ============================================================

SELECT
    test_name,
    COUNT(*) AS total_tests,
    ROUND(SUM(test_cost), 2) AS total_test_cost,
    ROUND(AVG(test_cost), 2) AS average_test_cost
FROM lab_tests
GROUP BY test_name
ORDER BY total_test_cost DESC
LIMIT 5;


-- ============================================================
-- ADVANCED LEVEL
-- ============================================================


-- ============================================================
-- Q11. Top 3 Diagnoses Within Each Department
-- ============================================================
-- Find the top 3 most common diagnoses within each department
-- and assign a rank to each diagnosis.
-- ============================================================

WITH diagnosis_counts AS (
    SELECT
        department,
        diagnosis,
        COUNT(*) AS total_diagnosis
    FROM admissions
    GROUP BY
        department,
        diagnosis
),

ranked_diagnoses AS (
    SELECT
        department,
        diagnosis,
        total_diagnosis,
        RANK() OVER (
            PARTITION BY department
            ORDER BY total_diagnosis DESC
        ) AS diagnosis_rank
    FROM diagnosis_counts
)

SELECT
    department,
    diagnosis,
    total_diagnosis,
    diagnosis_rank
FROM ranked_diagnoses
WHERE diagnosis_rank <= 3
ORDER BY
    department,
    diagnosis_rank;


-- ============================================================
-- Q12. Patients with Above-Average Total Medical Expenses
-- ============================================================
-- Find patients whose total medical expenses are greater
-- than the average total medical expense across all patients.
-- ============================================================

WITH patient_expenses AS (
    SELECT
        patient_id,
        SUM(medical_expenses) AS total_expense
    FROM admissions
    GROUP BY patient_id
)

SELECT
    patient_id,
    ROUND(total_expense, 2) AS total_expense,
    ROUND(
        (
            SELECT AVG(total_expense)
            FROM patient_expenses
        ),
        2
    ) AS average_patient_expense
FROM patient_expenses
WHERE total_expense > (
    SELECT AVG(total_expense)
    FROM patient_expenses
)
ORDER BY total_expense DESC;


-- ============================================================
-- Q13. Monthly Medical Expenses and Month-over-Month Change
-- ============================================================
-- Calculate total medical expenses for each month and
-- compare each month with the previous month.
-- ============================================================

WITH monthly_expenses AS (
    SELECT
        DATE_TRUNC('month', admission_date) AS month,
        SUM(medical_expenses) AS total_expenses
    FROM admissions
    GROUP BY DATE_TRUNC('month', admission_date)
),

monthly_comparison AS (
    SELECT
        month,
        total_expenses,
        LAG(total_expenses) OVER (
            ORDER BY month
        ) AS previous_month_expense
    FROM monthly_expenses
)

SELECT
    month,
    ROUND(total_expenses, 2) AS total_expenses,
    ROUND(previous_month_expense, 2) AS previous_month_expense,

    ROUND(
        total_expenses - previous_month_expense,
        2
    ) AS month_over_month_change,

    ROUND(
        (
            (total_expenses - previous_month_expense)
            / NULLIF(previous_month_expense, 0)
        ) * 100,
        2
    ) AS month_over_month_rate

FROM monthly_comparison
ORDER BY month;


-- ============================================================
-- Q14. Department Performance Report
-- ============================================================
-- Create a department performance report containing:
-- 1. Total admissions
-- 2. Average length of stay
-- 3. Total medical expenses
-- 4. Average patient satisfaction
-- 5. Total readmissions
-- 6. Readmission rate
-- 7. Rank based on total medical expenses
-- ============================================================

WITH department_performance AS (
    SELECT
        department,

        COUNT(*) AS total_admissions,

        ROUND(
            AVG(length_of_stay),
            2
        ) AS average_length_of_stay,

        ROUND(
            SUM(medical_expenses),
            2
        ) AS total_medical_expenses,

        ROUND(
            AVG(patient_satisfaction),
            2
        ) AS average_patient_satisfaction,

        COUNT(
            CASE
                WHEN readmission = 'Yes' THEN 1
            END
        ) AS total_readmissions,

        ROUND(
            COUNT(
                CASE
                    WHEN readmission = 'Yes' THEN 1
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS readmission_rate

    FROM admissions
    GROUP BY department
)

SELECT
    department,
    total_admissions,
    average_length_of_stay,
    total_medical_expenses,
    average_patient_satisfaction,
    total_readmissions,
    readmission_rate,

    RANK() OVER (
        ORDER BY total_medical_expenses DESC
    ) AS expense_rank

FROM department_performance
ORDER BY expense_rank;


-- ============================================================
-- Q15. Department Requiring the Most Attention
-- ============================================================
-- Identify the department that requires the most attention
-- based on:
--
-- 1. Admission volume
-- 2. Emergency admission percentage
-- 3. Average length of stay
-- 4. Medical expenses
-- 5. Readmission rate
-- 6. Patient satisfaction
-- 7. Laboratory costs
--
-- NOTE:
-- Admissions and lab_tests are aggregated separately to
-- prevent duplicate admission rows caused by the one-to-many
-- relationship between admissions and lab tests.
-- ============================================================


-- ------------------------------------------------------------
-- Step 1: Calculate admission-related metrics
-- ------------------------------------------------------------

WITH department_admissions AS (

    SELECT
        department,

        COUNT(*) AS admission_volume,

        ROUND(
            COUNT(
                CASE
                    WHEN admission_type = 'Emergency'
                    THEN 1
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS emergency_percentage,

        ROUND(
            AVG(length_of_stay),
            2
        ) AS average_length_of_stay,

        ROUND(
            SUM(medical_expenses),
            2
        ) AS total_medical_expenses,

        ROUND(
            COUNT(
                CASE
                    WHEN readmission = 'Yes'
                    THEN 1
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS readmission_rate,

        ROUND(
            AVG(patient_satisfaction),
            2
        ) AS average_satisfaction

    FROM admissions
    GROUP BY department
),

-- ------------------------------------------------------------
-- Step 2: Calculate laboratory costs separately
-- ------------------------------------------------------------

department_labs AS (

    SELECT
        a.department,
        ROUND(
            SUM(l.test_cost),
            2
        ) AS total_lab_cost

    FROM admissions AS a

    INNER JOIN lab_tests AS l
        ON a.admission_id = l.admission_id

    GROUP BY a.department
),

-- ------------------------------------------------------------
-- Step 3: Combine department metrics
-- ------------------------------------------------------------

department_metrics AS (

    SELECT
        a.department,
        a.admission_volume,
        a.emergency_percentage,
        a.average_length_of_stay,
        a.total_medical_expenses,
        a.readmission_rate,
        a.average_satisfaction,
        COALESCE(l.total_lab_cost, 0) AS total_lab_cost

    FROM department_admissions AS a

    LEFT JOIN department_labs AS l
        ON a.department = l.department
),

-- ------------------------------------------------------------
-- Step 4: Calculate attention score
-- ------------------------------------------------------------
-- Higher values indicate greater attention:
-- Admission volume
-- Emergency percentage
-- Average length of stay
-- Medical expenses
-- Readmission rate
-- Laboratory costs
--
-- Lower patient satisfaction increases attention score.
-- ------------------------------------------------------------

scored_departments AS (

    SELECT
        *,
        
        (
            admission_volume
            + emergency_percentage
            + average_length_of_stay
            + (total_medical_expenses / 10000)
            + readmission_rate
            + (10 - average_satisfaction)
            + (total_lab_cost / 10000)
        ) AS attention_score

    FROM department_metrics
)

-- ------------------------------------------------------------
-- Step 5: Rank departments
-- ------------------------------------------------------------

SELECT
    department,
    admission_volume,
    emergency_percentage,
    average_length_of_stay,
    total_medical_expenses,
    readmission_rate,
    average_satisfaction,
    total_lab_cost,
    ROUND(attention_score, 2) AS attention_score,

    RANK() OVER (
        ORDER BY attention_score DESC
    ) AS attention_rank

FROM scored_departments
ORDER BY attention_rank;