# Datenvalidierung (Row Counts & Foreign Key Consistency)

Die Validierung wurde durchgeführt, um sicherzustellen, dass beide Datensätze (Small und Large Dataset) korrekt geladen wurden und alle Fremdschlüsselbeziehungen konsistent sind.  
Hierfür wurden die Skripte `validation/row_counts.sql` und `validation/fk_validation.sql` verwendet.  
Bei beiden Läufen lagen **alle Orphan-Werte bei 0**, d. h. es existieren **keine Fremdschlüsselverletzungen**.

---

## **1. Small Dataset – Validation Results**

### **Row Counts**
| Table              | Row Count |
|--------------------|-----------|
| roles              | 5 |
| locations          | 5 |
| customers          | 50 |
| employees          | 50 |
| projects           | 30 |
| project_baselines  | 30 |
| actual_costs       | 300 |
| project_kpis       | 300 |
| assignments        | 3 000 |
| work_schedule      | 5 000 |

### **Foreign Key Validation**
Alle Orphans = **0**

---

## **2. Large Dataset – Validation Results**

### **Row Counts**
| Table              | Row Count |
|--------------------|-----------|
| assignments        | 100 000 |
| work_schedule      | 73 000 |
| actual_costs       | 40 000 |
| project_kpis       | 20 000 |
| roles              | 5 |
| locations          | 10 |
| customers          | 500 |
| projects           | 200 |
| employees          | 200 |
| project_baselines  | 200 |

### **Foreign Key Validation**
Alle Orphans = **0**

---

## **3. Fazit**

- Beide Datensätze wurden erfolgreich geladen.  
- Die Row Counts sind plausibel und entsprechen den generierten Datenmengen.  
- Es liegen **keine Fremdschlüsselverletzungen** vor.  
- Das Datenmodell ist stabil und unterstützt sowohl kleine als auch große Datenvolumen zuverlässig.
