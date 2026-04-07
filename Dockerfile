FROM python:3.12-slim

# 1. Set working directory
WORKDIR /app

# 2. Copy ONLY requirements first to cache them
COPY requirements.txt .

# 3. Remove the '-e .' line automatically just in case you forgot
RUN sed -i '/-e ./d' requirements.txt && \
    pip install --no-cache-dir -r requirements.txt

# 4. Now copy your entire project (including setup.py)
COPY . .

# 5. Install your project as a package using setup.py 
# (This is the "correct" version of what -e . was trying to do)
RUN pip install .

# 6. Start the app
EXPOSE 5000
CMD ["python", "app.py"]