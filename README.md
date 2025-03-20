# ESXi Tools - VMware PowerCLI Automation

**ESXi Tools** is a PowerShell script that automates various operations on VMware ESXi hosts using **VMware PowerCLI**.  
It allows you to:
- **Import vSwitches**
- **Import Port Groups**
- **Export vSwitch and Port Group configurations**
- **Massively change the root password on multiple ESXi hosts**

---

## 🚀 Prerequisites
Before running the script, make sure you have:
1. **PowerShell 5.1 or higher** installed.
2. **VMware PowerCLI** installed:
   - If it is not installed, the script will automatically download it.
3. **Administrative access** to ESXi hosts.
4. **CSV files** containing host lists and configurations.

---

## 📂 Required File Structure
The script uses **CSV files** to import or export configurations.

### 📌 1. Hosts CSV (`hosts.csv`)
Contains the list of ESXi hosts where operations will be performed.

**Example:**
```
ESXiHost
esxi01.domain.local
esxi02.domain.local
esxi03.domain.local
```

---

### 📌 2. vSwitches CSV (`vswitches.csv`)
Contains vSwitch configurations to be imported into the ESXi hosts.

**Example:**
```
VSwitch,MTU,NICs
vSwitch0,1500,vmnic0
vSwitch1,9000,vmnic1,vmnic2
```

- `VSwitch` → Name of the vSwitch.
- `MTU` → MTU size.
- `NICs` → Comma-separated list of physical NICs assigned to the vSwitch.

---

### 📌 3. Port Groups CSV (`portgroups.csv`)
Contains Port Group configurations for the ESXi hosts.

**Example:**
```
VSwitch,PortGroup,VLAN
vSwitch0,Management,0
vSwitch0,VM_Network,100
vSwitch1,Storage,200
```

- `VSwitch` → The vSwitch where the Port Group is created.
- `PortGroup` → Name of the Port Group.
- `VLAN` → VLAN ID (use `0` for no VLAN).

---

## 🛠️ How to Use
Run the script in PowerShell:

```
.\esxi-tools.ps1
```

You will be presented with a menu:

```
===================================
            ESXi Tools             
===================================
1. Import vSwitches
2. Import Port Groups
3. Export vSwitch & Port Groups Config
4. Change ESXi Root Password
5. Exit
===================================
Select an option:
```

---

### 🔹 1. Import vSwitches
This option reads the **`vswitches.csv`** file and creates vSwitches on the specified hosts.

✅ The script will:
- Ask for the **`hosts.csv`** file.
- Ask for the **`vswitches.csv`** file.
- Connect to each ESXi host and **create the vSwitches**.

---

### 🔹 2. Import Port Groups
This option reads the **`portgroups.csv`** file and creates Port Groups on the specified hosts.

✅ The script will:
- Ask for the **`hosts.csv`** file.
- Ask for the **`portgroups.csv`** file.
- Connect to each ESXi host and **create the Port Groups**.

---

### 🔹 3. Export vSwitch & Port Groups Config
This option exports **existing vSwitch and Port Group configurations** from a selected ESXi host.

✅ The script will:
- Ask for the **hostname** of the ESXi to export from.
- Connect to the ESXi host.
- Generate:
  - **`<hostname>-vswitches.csv`** (containing vSwitch configurations).
  - **`<hostname>-portgroups.csv`** (containing Port Group configurations).

---

### 🔹 4. Change ESXi Root Password
This option allows **mass password changes for root** on multiple ESXi hosts.

✅ The script will:
- Ask for the **`hosts.csv`** file.
- Ask for the **current root password** (in plain text).
- Ask for the **new root password** (in plain text).
- Connect to each ESXi host with the **current password**.
- Change the root password to the **new one**.
- Display a **success report**.

**Example Output:**
```
Connecting to esxi01.domain.local...
SUCCESS: Password changed on esxi01.domain.local
Connecting to esxi02.domain.local...
SUCCESS: Password changed on esxi02.domain.local

Password change summary:
esxi01.domain.local -> NewPassword123
esxi02.domain.local -> NewPassword123
```

---

## ⚠️ Important Notes
- **PowerCLI must be installed**. The script will attempt to install it if missing.
- **Ensure CSV files are correctly formatted** before running import actions.
- **The root password change operation is irreversible**. Double-check the new password before executing.

---

## 📜 License
This script is provided **as-is** without any warranty. Use at your own risk.

---

## 🏆 Contributions
Feel free to **fork, modify, or contribute** to this project!
