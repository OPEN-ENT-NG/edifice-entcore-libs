# À propos de EntCore Libs

* Licence : [AGPL v3](http://www.gnu.org/licenses/agpl.txt) - Copyright Edifice
* Financeur(s) : Edifice
* Développeur(s) : Edifice
* Description : l’application entcore est un noyau d'ENT modulaire et performant.


# Description

`edifice-entcore-libs` est une librairie mettant à disposition des applis de l'ENT telles que [entcore](https://github.com/edificeio/entcore/)
des fonctionnalités et les modules minimaux permettant le déploiement dans le cloud. 

# Modules mis à disposition

## common

`Common` est une librairie mettant à disposition les capacités suivantes de l'ENT :
- le storage (filesystem, s3, GridFS, etc.)
- l'interface avec le module app-registry
- mesure d'audienceee
- les contrôlleurs de base (configuration, et l'exposition des droits)
- l'envoi d'email
- les fonctionnalités de l'explorateur universel
- les accès aux bases de données
- l'envoi de SMS

# session

Ce module déploie le verticle permettant de gérer le cycle de vie des sessions des utilisateurs (création, récupération,
suppression).

# broker-parent

Module chapeau contenant :
- des librairies permettant aux autres modules de définir des _listeners_ typés sur un broker (NATS par défaut)
- un verticle écoutant et répondant sur le broker (NATS par défaut)

Ce dépôt est un miroir officiel du dépôt Edifice : https://github.com/edificeio/edifice-entcore-libs
