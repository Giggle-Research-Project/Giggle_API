FROM python:3.11

WORKDIR /code

# Install system dependencies for OpenCV
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0

COPY ./requirements.txt /code/requirements.txt

# Install gdown to download files from Google Drive
RUN pip install --no-cache-dir gdown==5.2.0

# Create a directory for models
RUN mkdir -p /code/models

# Copy the download script into the container
COPY ./download_models.py /code/download_models.py

# Run the script to download the models
RUN python /code/download_models.py

RUN pip install --no-cache-dir -r requirements.txt

COPY ./app.py /code/app.py
COPY ./function_01 /code/function_01
COPY ./function_02 /code/function_02
COPY ./function_03 /code/function_03
COPY ./function_04 /code/function_04

# Expose the port your FastAPI app will run on
EXPOSE 80

# Run FastAPI with Uvicorn
CMD [ "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "80" ]