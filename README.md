# ✈️ Projet Data – Conception et exploitation d’une base de données du trafic aérien (ADP)

## 📌 Description
Ce projet a pour objectif la **conception, la reconstruction et l’exploitation d’une base de données relationnelle** dédiée au **trafic aérien** à partir de fichiers CSV nettoyés.  
Il met l’accent sur la **qualité des données**, l’**intégrité référentielle** et la **préparation à l’analyse décisionnelle**.

Le projet s’inscrit dans une démarche Data Engineering et Data Management, depuis l’importation des données jusqu’à la mise en place d’un **modèle relationnel robuste**.

---

## 🎯 Objectifs du projet
- Recréer une base de données à partir de fichiers CSV existants  
- Concevoir un **modèle relationnel cohérent et normalisé**
- Garantir la **qualité, la cohérence et l’intégrité des données**
- Préparer la base pour des **analyses métier avancées**

---

## 🛠️ Technologies utilisées
- **SQL Server Express** : stockage et gestion de la base de données  
- **R** : scripts d’importation et de contrôle des données  
- **Shiny** : visualisation et exploration des données  
- **GitHub** : gestion de version et collaboration  

---

## 📂 Jeux de données
Les données utilisées sont issues de fichiers CSV nettoyés :

- `airlines_clean.csv` → compagnies aériennes  
- `airports_clean.csv` → aéroports  
- `flights_clean.csv` → vols  
- `planes_clean.csv` → avions  
- `weather_clean.csv` → données météorologiques  

---

## 🧩 Missions réalisées

### 🔹 Mission 1 – Importation des données
- Création des tables dans SQL Server  
- Importation via des **scripts R personnalisés**  
- Vérification de la volumétrie (nombre de lignes)  
- Contrôle des types de données  
- Détection des valeurs NULL et des tables vides  

✔️ Importation validée et base correctement alimentée

---

### 🔹 Mission 2 – Structuration et qualité des données
- Identification des **clés primaires (PK)**  
- Détection et suppression des doublons  
- Vérification des valeurs manquantes  
- Définition des relations fonctionnelles  
- Mise en place des **clés étrangères (FK)**  

#### Clés primaires mises en place :
- `airlines (carrier)`
- `airports (faa)`
- `planes (tailnum)`
- `weather (year, month, day, hour, origin)`
- `flights (year, month, day, hour, carrier, flight)`

#### Relations principales :
- `planes → flights`
- `airlines → flights`
- `airports → flights (origin, dest)`
- `airports → weather`

✔️ Intégrité référentielle garantie

---

### 🔹 Sécurisation et contrôle final
- Vérification des contraintes PK et FK  
- Harmonisation des types de données  
- Gestion des rôles (administrateur / utilisateur)  

✔️ Base fiable, sécurisée et prête pour l’exploitation

---

## 📊 Résultats
- Base de données propre et cohérente  
- Modèle relationnel robuste et normalisé  
- Données prêtes pour l’analyse décisionnelle  
- Fondation solide pour des requêtes métier avancées  

---

## 🚀 Prochaine étape
➡️ **Mission 3 : Requêtes métier avancées et analyses décisionnelles**  
Exploitation complète de la base pour répondre à des problématiques business.

---

## 📎 Documentation
Les supports de présentation et documents associés sont disponibles dans le dépôt GitHub.

---

💡 *Projet réalisé dans un cadre académique – Master en Systèmes d’Information / Data.*
