Readme géneré par IA

# Infrastructure GCP avec Terraform

Ce dépôt contient une infrastructure Google Cloud Platform (GCP) définie avec Terraform. Le projet déploie un réseau personnalisé, des sous-réseaux, des instances Compute Engine, et une passerelle réseau en s'appuyant sur les différents fichiers `.tf` du répertoire.

## Prérequis

- Compte Google Cloud avec droits suffisants pour créer des ressources réseau et Compute Engine
- Terraform `>= 1.5`
- SDK Google Cloud (`gcloud`) configuré (authentification et projet actif)
- Clés de service si l'exécution se fait dans un environnement CI/CD

## Structure du projet

- `main.tf` : point d'entrée qui orchestre les autres fichiers et configure le provider GCP.
- `variables.tf` : liste des variables d'entrée avec leurs valeurs par défaut et descriptions.
- `firewalls.tf` : règles de pare-feu permettant ou bloquant le trafic réseau.
- `subnets.tf` : définition des sous-réseaux dans le VPC personnalisé.
- `instances.tf` : ressources Compute Engine, métadonnées et éventuels disques associés.
- `gateway.tf` : configuration de la passerelle (NAT ou autres composants réseau externes).
- `terraform.tfstate` / `terraform.tfstate.backup` : état Terraform (ne jamais modifier manuellement).

## Configuration des variables

Adaptez les variables dans `variables.tf` ou via un fichier `terraform.tfvars` pour refléter votre projet :

```hcl
project_id   = "mon-projet-gcp"
region       = "europe-west1"
network_cidr = "10.0.0.0/16"
```

Vous pouvez aussi passer les valeurs en ligne de commande :

```bash
terraform apply -var "project_id=mon-projet-gcp" -var "region=europe-west1"
```

## Déploiement

1. Initialiser le backend et les providers :
   ```bash
   terraform init
   ```
2. Vérifier le plan d'exécution :
   ```bash
   terraform plan
   ```
3. Appliquer les changements :
   ```bash
   terraform apply
   ```
4. Détruire les ressources lorsque nécessaire :
   ```bash
   terraform destroy
   ```

## Améliorations possibles

- Utiliser des workspaces Terraform pour isoler les environnements (dev, test, prod).
- Stocker le fichier d'état dans un backend distant sécurisé (GCS bucket avec verrouillage par exemple).
- Versionner les variables sensibles via un gestionnaire de secrets (Secret Manager, Vault).
- Mettre en place des tests d'infrastructure (ex. Terratest) pour valider les changements majeurs.

## Ressources complémentaires

- [Documentation Terraform GCP](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Bonnes pratiques Terraform](https://developer.hashicorp.com/terraform/tutorials)
- [Console Google Cloud](https://console.cloud.google.com/)
