# 🚀 Production-Grade Azure Infrastructure with Terraform – Auto Scaling Demo

[![Watch the demo](https://img.youtube.com/vi/z1xgDxK7fOM/maxresdefault.jpg)](https://www.youtube.com/watch?v=z1xgDxK7fOM&t=23s)

▶ **Watch the complete live demo here:**  
https://www.youtube.com/watch?v=z1xgDxK7fOM&t=23s

This project demonstrates how to build a **production-style scalable Azure infrastructure using Terraform** and test its autoscaling capability in real time.

The goal of this project was to understand how modern cloud systems automatically handle workload spikes by dynamically adding or removing compute resources.

All infrastructure components are deployed using **Terraform (Infrastructure as Code)**, making the environment reproducible, consistent, and easy to manage.

---

# 🏗️ Architecture Overview

The Terraform configuration provisions the following Azure resources:

- Azure **Resource Group**
- **Virtual Network**
- **Subnet**
- **Standard Public IP**
- **Azure Load Balancer**
- **Backend Address Pool**
- **Health Probe**
- **Linux Virtual Machine Scale Set (VMSS)**
- **Autoscaling rules using Azure Monitor**

This setup simulates a **production-style architecture** where traffic is distributed across multiple virtual machines and scaling happens automatically depending on system load.

---

# ⚙️ How the Project Works

A lightweight monitoring webpage is deployed on each virtual machine instance.  
The webpage displays useful system information such as:

- Hostname
- MAC Address
- CPU usage
- Memory usage
- Visitor count

When users access the application through the **Azure Load Balancer**, requests are distributed across the VM instances in the scale set.

To test autoscaling behavior, CPU load is generated on the virtual machines.  
Azure Monitor continuously tracks CPU utilization and evaluates the autoscale rules.

When CPU usage increases beyond the defined threshold:

➡ Azure **automatically scales out** by creating additional VM instances.

When the workload drops:

➡ Azure **scales in** by removing unnecessary instances.

This demonstrates how Azure automatically maintains performance while optimizing resource usage.

---

# 🌍 Key Learning Outcomes

Working on this project helped me better understand:

- How **Azure Virtual Machine Scale Sets** work
- How **Azure Monitor Autoscale rules** trigger scaling decisions
- Load balancing across multiple VM instances
- Real-time infrastructure scaling based on CPU metrics
- Infrastructure automation using **Terraform**

It also highlights how **cloud platforms manage infrastructure dynamically** to handle changing workloads efficiently.

---

# 🛠️ Technologies Used

- Terraform
- Microsoft Azure
- Azure Virtual Machine Scale Sets (VMSS)
- Azure Load Balancer
- Azure Monitor Autoscaling
- Linux (Ubuntu)

---

# 📌 Key Highlights

✔ Infrastructure fully deployed using **Terraform**  
✔ **Automatic scaling** based on CPU utilization  
✔ **Load balancing across VM instances**  
✔ Real-time **autoscale testing under simulated load**  
✔ Demonstrates **cloud-native scalability concepts**

---

# ⚠️ Challenges Faced


One of the main challenges during this project was **triggering the autoscaling behavior using CPU utilization**.

Initially, even after generating load on the virtual machines, the **CPU utilization metric was not increasing enough to trigger the autoscale rule**.

To simulate higher CPU load, additional stress commands were executed on the VM instances. However, even after generating artificial load, the CPU usage still remained below the autoscaling threshold.

After several troubleshooting attempts and testing different configurations, the autoscale rule threshold was adjusted to **1% CPU utilization** in order to properly observe the scaling behavior during the demo.

Once the threshold was lowered, Azure Monitor successfully detected the CPU activity and the **VM Scale Set began scaling out as expected**, demonstrating the autoscaling functionality in real time.

This process required multiple iterations and helped in better understanding how **Azure autoscale metrics and evaluation windows behave in practical scenarios**.

---


# 🎯 Project Goal

The purpose of this project was to gain practical experience in building **scalable cloud infrastructure** and understanding how **autoscaling works in real-world environments**.

Instead of only studying theory, this project demonstrates how infrastructure behaves under load and how cloud platforms automatically adapt to changing demand.
