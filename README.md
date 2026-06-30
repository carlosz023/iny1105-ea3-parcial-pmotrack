# INY1105 — EA3: Evaluación Parcial N°03 - Solución PMOTrack

**Autor:** Carlos Campos Zegarra  
**Institución:** DuocUC  
**Curso:** Tecnologías de Virtualización  

---

## 1. Descripción de la Arquitectura Objetivo
La consultora PMOTrack requería el despliegue de su herramienta de gestión de proyectos (Redmine) acoplada a una base de datos robusta (PostgreSQL). Se diseñó e implementó una arquitectura en dos capas orquestada en un clúster de Amazon EKS dentro del namespace personalizado `pmotrack`:
* **Capa de Backend (Base de Datos):** Un pod de PostgreSQL v16 aislado internamente, cuyo almacenamiento es persistente y seguro.
* **Capa de Frontend (Aplicación Web):** Un pod de Redmine v5 capaz de escalar horizontalmente de forma automática según la demanda de CPU, expuesto hacia el exterior para el acceso de los usuarios de la consultora.

---

## 2. Decisiones Técnicas Remarcables
* **Gestión de Secretos (Security):** Las credenciales de acceso a la base de datos (`POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`) se abstrajeron por completo del código utilizando un objeto `Secret` de Kubernetes mapeado en Base64.
* **Almacenamiento Persistente:** Se utilizaron objetos `PersistentVolume` y `PersistentVolumeClaim` configurados con la política `hostPath` apuntando al disco del nodo del laboratorio bajo una clase manual. Esto asegura que si el Pod de PostgreSQL falla o se recrea, los datos no se pierdan de forma volátil.
* **Networking y Exposición:** * La base de datos se expuso mediante un servicio tipo `ClusterIP` (puerto 5432), garantizando que solo sea accesible de manera interna por Redmine.
  * El frontend de Redmine se expuso mediante un servicio tipo `NodePort` mapeado estáticamente al puerto `30080`, permitiendo el acceso web público a través de las IPs de los nodos de AWS.
* **Autoscaling (HPA):** Se configuraron límites y solicitudes de recursos (`resources.requests.cpu: 200m`) en el contenedor de Redmine. Esto habilitó al componente `Metrics Server` la recolección de métricas precisas para gatillar el autoescalado horizontal (HPA) asignando un rango de entre 1 y 5 réplicas cuando el uso de CPU supere el 50%.

---

## 3. Instrucciones de Despliegue Paso a Paso

Para replicar esta infraestructura de principio a fin de manera limpia y ordenada, ejecute los siguientes comandos en orden jerárquico dentro de AWS CloudShell:

### Paso 1: Preparar el entorno y levantar el Clúster
```bash
cd iny1105-ea3-parcial-pmotrack
bash commons/scripts/setup-cloudshell.sh
bash commons/scripts/create-cluster.sh
