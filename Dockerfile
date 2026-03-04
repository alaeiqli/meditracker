FROM python:3.9-slim

# Installer les dépendances systèmes nécessaires pour certains packages Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copier requirements.txt en premier pour utiliser le cache Docker
COPY requirements.txt /app/

# Installer les dépendances Python
RUN python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt

# Copier le reste de l'application
COPY . /app

# Exposer le port Flask
EXPOSE 5000

# Commande de lancement
CMD ["python", "app.py"]