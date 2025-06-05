# Prueba Práctica DevSecOps: Simulación de CI/CD Completo

## Descripción de la Prueba
El candidato deberá diseñar y construir un flujo de CI/CD completo utilizando un repositorio Git y herramientas DevSecOps para demostrar sus habilidades en automatización de procesos, despliegue seguro de aplicaciones y resolución de problemas técnicos. La prueba debe simular un entorno real donde se configuren diferentes parámetros de despliegue y medidas de seguridad según el ambiente.

## Tareas Principales

1. **Administración del Repositorio Git**
   - Configurar un repositorio Git (local o en la nube).
   - Definir accesos y permisos a usuarios.
   - Implementar un modelo de branching siguiendo un flujo de integración continua, como Git Flow.

2. **Pipeline de CI/CD Seguro**  
   Crear un pipeline de integración y despliegue continuo con medidas de seguridad que cumpla con:
   - **Compilación:** Construcción de un componente de software (open source o propio).
   - **Análisis de Seguridad (Opcional):** Escaneo de vulnerabilidades de dependencias y código (utilizando herramientas de análisis de seguridad de preferencia).
   - **Despliegue:** Publicación de la aplicación en un ambiente (servidor, clúster o serverless).

3. **Configuración por Entorno**  
   Implementar configuraciones específicas y validaciones de seguridad según el ambiente de despliegue (desarrollo, staging).

4. **Infraestructura y Automatización (Opcional)**  
   Utilizar infraestructura como código (IaC) para aprovisionar lo   Utilizar infraestructura como código guridad habilitados. Incluir automatización de pruebas de seguridad y escaneo en el pipeline.

## Requisitos Técnicos

1. **Herramientas Autorizadas:**
   - Jenkins
   - Azure DevOps
   - GitLab (Cloud o On-Premise)
   - GitHub
   - Octopus Deploy
   - Cualquier container registry o repositorio de artefactos

2. **Herramientas de Análisis de Seguridad (Opcional):**  
   El candidato puede elegir la herramienta de análisis de seguridad que prefiera (por ejemplo, Snyk, SonarQube, OWASP Dependency-Check, Trivy, etc.).

3. **Proyecto de Software:**
   - Puede ser un proyecto open source o desarrollado por el candidato.
   - La funcionalidad del software no será evaluada; solo se evaluará el flujo de CI/CD y los controles de seguridad implementados.

## Detalles de la Implementación

1. **Modelo de Branching**  
   Implementar el flujo Git Flow:
                                                      nches temporales: `feature/*`, `release/*`, `hotfix/*`.

2. **Configuración del Pipeline de CI/CD Seguro**  
   Etapas principales:
   - **Build:** Compilar el código fuente y generar artefactos.
   - **S   - **S   - **S   - *):*   - **S   - **S   - **S   - *)d (dependencias y código fuente)   - **S   - **S   - **S   - *)as automatizad   - **S   - **S  ** Desplegar la aplicación en el ambiente correspondiente (solo dev y staging).

3. **Automatización de Infraestructura (Opcional)**  
   Utilizar herramientas de IaC, como Terraform, ARM Templates o Bicep, para crear los recursos necesarios con políticas de seguridad habili   Utilizar herramientas deo.

4. **Despliegue Seguro Multiambiente**  
   Configurar variables o arc   Configurar variables o arc   Configurar variables o arc   Configurar variables o arc   Configurar variables o arc   Configurar vo a claves sensibles de forma segura (por ejemplo, usando Key Vault o Secrets Management).

## Evaluac## Evaluac## Evaluac## Evaluac## Evaluac## Evaluac## Evaluac## Evaluac## Evaluac## Evaluac## Evaluac## Eval                                                         |
|------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| Experiencia y dominio en las herramientas            | Uso adecuado y eficiente de las herramientas DevSecOps seleccionadas                                |
| Implemen| Implemen| Implemen| Implemen| Implemen| Implemen| Iguración correcta de escaneos y controles de seguridad                                         |
| Proceso de compilación y despliegue                  | Proceso de construcción y despliegue sin errores y eficiente                                         |
| Creatividad en la resolución del problema            | Soluciones adicionales o mejoras implementadas                                                      |
| Automatización de pruebas (Opcional)                 | Inclusión de pruebas automatizadas y de seguridad en el pipeline                                     |
| Infraestructura como código (Opcional)               | Imp| Infraestructura como código (Opcional)               | Imp| Infraestructura como código (Opcional)               | Imp| Infraestructura como código  la prueba, se agendará una sesión con el candidato para presentar y defender el trabajo realizado, explicando las decisiones técnicas tomadas durante la implementación.  

[![CI/CD Pipeline Seguro](https://github.com/blyzer/babel-billet/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/blyzer/babel-billet/actions/workflows/ci-cd.yml)