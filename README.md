# 🏥 Healthcare Data Analysis Using SQL

## 📌 Project Overview

This project focuses on analyzing healthcare data using **PostgreSQL and SQL** to uncover meaningful insights related to patient demographics, hospital admissions, medical expenses, doctors, insurance coverage, readmissions, patient satisfaction, and laboratory testing.

The project uses a **synthetic healthcare dataset** designed for analytical and learning purposes. The data is organized into multiple related tables to simulate a real-world hospital database.

The analysis follows a structured SQL workflow, beginning with database and table creation and progressing from basic analytical queries to intermediate and advanced SQL techniques.

The main objective is to transform healthcare data into meaningful insights that can help understand **hospital operations, patient trends, departmental performance, healthcare costs, insurance coverage, readmission patterns, and laboratory utilization**.

---

## 🎯 Project Objectives

- Analyze patient demographics and characteristics.
- Understand hospital admission patterns.
- Analyze admissions across different departments.
- Compare emergency, urgent, and elective admissions.
- Identify departments with higher medical expenses.
- Analyze monthly admission trends.
- Combine patient, doctor, and admission information using SQL JOINs.
- Identify doctors handling the highest number of admissions.
- Analyze insurance coverage and patient expenses.
- Measure readmission rates across departments.
- Analyze laboratory test utilization and costs.
- Identify the most common diagnoses within departments.
- Compare patient expenses against the overall average.
- Analyze month-over-month changes in medical expenses.
- Evaluate overall departmental performance.
- Identify departments requiring greater operational attention.

---

## 🛠️ Tools & Technologies

- PostgreSQL
- SQL
- pgAdmin 4
- Git & GitHub

---

# 🔄 Project Steps

## 1. Set Up the Environment

The project was developed using **PostgreSQL** with **pgAdmin 4** for database management and SQL analysis.

### Tools Used

- PostgreSQL
- pgAdmin 4
- SQL
- Git
- GitHub

---

## 2. Dataset Creation

A synthetic healthcare dataset was created for this project to simulate a realistic hospital database environment.

The dataset is divided into four related CSV files:

### 👤 Patients Dataset

**File:** `healthcare_patients.csv`

Contains **5,000 patient records** with information such as:

- Patient ID
- Age
- Gender
- City
- Blood Group

The patient dataset contains demographic information that can be connected to hospital admission records through `patient_id`.

---

### 👨‍⚕️ Doctors Dataset

**File:** `healthcare_doctors.csv`

Contains the hospital's doctor information:

- Doctor ID
- Doctor Name
- Department

The doctor table is used to connect doctors with admission records through `doctor_id`.

---

### 🏥 Admissions Dataset

**File:** `healthcare_admissions_5000.csv`

Contains **5,000 hospital admission records**.

The dataset includes:

- Admission ID
- Patient ID
- Admission Date
- Discharge Date
- Department
- Diagnosis
- Treatment
- Doctor ID
- Insurance Provider
- Admission Type
- Room Type
- Length of Stay
- Medical Expenses
- Insurance Coverage
- Patient Satisfaction
- Readmission
- Follow-up Required

This table acts as the central table for most of the hospital operational and financial analysis.

---

### 🧪 Laboratory Tests Dataset

**File:** `healthcare_lab_tests_8000.csv`

Contains **8,000 laboratory test records**.

The dataset includes:

- Test ID
- Admission ID
- Patient ID
- Test Name
- Test Date
- Test Result
- Test Cost

The laboratory data is connected to hospital admissions and patients, allowing analysis of laboratory utilization and testing costs.

---

# 🗄️ 3. Database Design

The project uses four relational tables:

```text
Patients
   │
   │ patient_id
   ▼
Admissions
   │
   ├──────────────► Doctors
   │                 doctor_id
   │
   │ admission_id
   ▼
Lab Tests
