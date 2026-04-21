# Student Performance Predictor

A machine learning web application that predicts a student's **math score** based on demographic and academic factors. Built with Flask and scikit-learn, following a modular ML pipeline — containerised with Docker, stored in Azure Container Registry, and deployed on Azure Web App with CI/CD via GitHub Actions.

---

## What It Does

A user fills in a form with the following inputs and the app returns a predicted math score:

| Input | Type |
|---|---|
| Gender | Categorical |
| Race / Ethnicity | Categorical |
| Parental Level of Education | Categorical |
| Lunch Type | Categorical |
| Test Preparation Course | Categorical |
| Reading Score | Numeric |
| Writing Score | Numeric |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Web Framework | Flask |
| ML Library | scikit-learn |
| Boosting Models | XGBoost, CatBoost, AdaBoost |
| Data Processing | Pandas, NumPy |
| Visualisation | Matplotlib, Seaborn |
| Model Serialisation | Pickle |
| Model Selection | GridSearchCV |
| Containerisation | Docker |
| Container Registry | Azure Container Registry (ACR) |
| Hosting | Azure Web App |
| CI/CD | GitHub Actions |

---

## Project Structure

```
.
├── .github/
│   └── workflows/          # GitHub Actions CI/CD pipeline
├── artifacts/
│   ├── data.csv            # Full dataset (1000 rows, 8 columns)
│   ├── train.csv           # Training split (800 rows)
│   ├── test.csv            # Test split (200 rows)
│   ├── model.pkl           # Trained regression model
│   └── proprocessor.pkl    # Fitted preprocessor (scaler + encoder)
├── notebook/               # EDA and model experimentation notebooks
├── src/
│   ├── components/         # Data ingestion, transformation, model trainer
│   ├── pipeline/
│   │   └── predict_pipeline.py  # PredictPipeline and CustomData classes
│   ├── exception.py        # Custom exception with file/line info
│   ├── logger.py           # Timestamped file logging
│   └── utils.py            # save_object, load_object, evaluate_models
├── templates/
│   ├── index.html          # Landing page
│   └── home.html           # Prediction form and result
├── .dockerignore
├── .gitignore
├── Dockerfile
├── app.py                  # Flask app entry point
├── requirements.txt
└── setup.py
```

---

## Dataset

- **Source:** [Kaggle — Students Performance in Exams](https://www.kaggle.com/datasets/spscientist/students-performance-in-exams?datasetId=74977)
- **Size:** 1000 rows × 8 columns
- **Target variable:** `math_score`
- **Features:** gender, race/ethnicity, parental level of education, lunch type, test preparation course, reading score, writing score
- **No missing values or duplicates**

### Score Statistics

| Subject | Mean | Std | Min | Max |
|---|---|---|---|---|
| Math | 66.09 | 15.16 | 0 | 100 |
| Reading | 69.17 | 14.60 | 17 | 100 |
| Writing | 68.05 | 15.20 | 10 | 100 |

---

## Notebooks

The `notebook/` folder contains two Jupyter notebooks covering the full ML lifecycle.

### 1. EDA — Student Performance Indicator

Covers complete exploratory data analysis:

**Data Checks**
- No missing values or duplicates found across all 8 columns
- 3 numeric features and 5 categorical features

**Key Findings**

- **Gender:** Nearly balanced — 518 female (48%) and 482 male (52%). Females score higher overall but males score higher in Maths specifically.
- **Lunch:** Students with standard lunch consistently outperform those on free/reduced lunch across all subjects and both genders.
- **Race/Ethnicity:** Group E students score the highest; Group A the lowest across all three subjects. Lower socioeconomic groups tend to have lower average scores.
- **Parental Education:** Students whose parents hold a master's or bachelor's degree score higher. Effect is stronger on male students than female students.
- **Test Preparation Course:** Students who completed the course scored higher across all three subjects.
- **Score Distribution:** Most students score between 60–80 in Maths and 50–80 in Reading and Writing. All three scores increase linearly with each other (confirmed via pairplot).
- **Outliers:** A small number of low outliers in Math (minimum score of 0), confirmed via boxplots.

**Visualisations:** Histograms, KDE plots, violin plots, pie charts, bar charts, count plots, box plots, pairplot

**Conclusions:**
- Student performance is most strongly related to lunch type, race/ethnicity, and parental education level
- Females lead in overall pass percentage and are more likely to be top scorers
- Completing the test preparation course is beneficial but the effect is moderate

---

### 2. Model Training

Trains and compares 9 regression models on the preprocessed dataset.

**Preprocessing**
- Categorical features → `OneHotEncoder`
- Numeric features → `StandardScaler`
- Train/test split: 80/20 (800 train, 200 test)
- Final feature matrix shape: (1000, 19)

**Model Comparison Results**

| Model | Test R² Score |
|---|---|
| **Ridge Regression** | **0.8806** ✅ |
| Linear Regression | 0.8804 |
| Random Forest | 0.8534 |
| CatBoost | 0.8516 |
| AdaBoost | 0.8514 |
| XGBoost | 0.8278 |
| Lasso | 0.8253 |
| K-Neighbors | 0.7838 |
| Decision Tree | 0.7572 |

**Best Model: Ridge Regression — 88.06% R² on test set**

The Linear Regression baseline achieved 88.04%, confirming strong linear relationships in the data. Decision Tree overfitted heavily (99.97% train vs 75.72% test R²).

---

## ML Pipeline

### Training
1. **Data Ingestion** — Reads the raw dataset, splits into train/test, saves to `artifacts/`
2. **Data Transformation** — Applies OneHotEncoding on categorical features and StandardScaler on numeric features; saves the fitted preprocessor to `artifacts/proprocessor.pkl`
3. **Model Training** — Trains multiple regression models using GridSearchCV, selects the best by R² score, saves to `artifacts/model.pkl`

### Inference
```python
pipeline = PredictPipeline()
data = CustomData(
    gender="female",
    race_ethnicity="group B",
    parental_level_of_education="bachelor's degree",
    lunch="standard",
    test_preparation_course="none",
    reading_score=72,
    writing_score=74
)
df = data.get_data_as_data_frame()
result = pipeline.predict(df)
```

---

## Getting Started (Local)

### Prerequisites
- Python 3.10+

### 1. Clone the repository
```bash
git clone https://github.com/ShibjiRout/Student-Performance.git
cd Student-Performance
```

### 2. Install dependencies
```bash
pip install -r requirements.txt
```

### 3. Run the app
```bash
python app.py
```

The app will be available at `http://localhost:8000`.

---

## Running with Docker

```bash
docker build -t student-performance .
docker run -p 8000:8000 student-performance
```

---

## Azure Deployment

```
GitHub Repository
      │
      │  push to main
      ▼
GitHub Actions (CI/CD)
      │
      ├─── docker build
      ├─── docker push ──► Azure Container Registry (ACR)
      │
      └─── Azure Web App pulls latest image from ACR
```

### Required GitHub Secrets

| Secret | Description |
|---|---|
| `AZURE_CREDENTIALS` | Azure service principal credentials (JSON) |
| `REGISTRY_LOGIN_SERVER` | ACR login server (e.g. `yourregistry.azurecr.io`) |
| `REGISTRY_USERNAME` | ACR username |
| `REGISTRY_PASSWORD` | ACR password |