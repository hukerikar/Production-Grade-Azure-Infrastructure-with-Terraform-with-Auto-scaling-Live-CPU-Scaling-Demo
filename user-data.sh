#!/bin/bash

apt-get update -y
apt-get install -y apache2 php jq
apt-get install -y stress

rm -f /var/www/html/index.html

cat <<'EOF' > /var/www/html/index.php
<?php

// Visitor counter
$counter_file = "/var/www/html/counter.txt";
if (!file_exists($counter_file)) {
    file_put_contents($counter_file, 0);
}
$visits = file_get_contents($counter_file);
$visits++;
file_put_contents($counter_file, $visits);

// Get MAC address
$mac = trim(shell_exec("cat /sys/class/net/eth0/address"));

// Get hostname (VM instance name)
$hostname = gethostname();

// Get CPU usage
$cpu_load = sys_getloadavg();
$cpu = $cpu_load[0];

// Get Memory usage
$meminfo = file_get_contents("/proc/meminfo");
preg_match('/MemTotal:\s+(\d+)/', $meminfo, $total);
preg_match('/MemAvailable:\s+(\d+)/', $meminfo, $available);

$total_mem = round($total[1] / 1024);
$avail_mem = round($available[1] / 1024);
$used_mem = $total_mem - $avail_mem;


?>

<!DOCTYPE html>
<html>
<head>
    <title>VMSS Live Monitor</title>

    <style>
        body { font-family: Arial; background:#111; color:#0f0; text-align:center; }
        .box { border:1px solid #0f0; padding:20px; margin:20px auto; width:60%; }
    </style>
</head>
<body>

<h1>🚀 Azure VMSS Live Monitor</h1>

<div class="box">
    <h2>Visitor Count: <?php echo $visits; ?></h2>
</div>

<div class="box">
    <h3>Serving VM</h3>
    <p><b>Hostname:</b> <?php echo $hostname; ?></p>
    <p><b>MAC Address:</b> <?php echo $mac; ?></p>
</div>

<div class="box">
    <h3>System Usage</h3>
    <p><b>CPU Load:</b> <?php echo $cpu; ?></p>
    <p><b>Memory Used:</b> <?php echo $used_mem; ?> MB / <?php echo $total_mem; ?> MB</p>
</div>

</body>
</html>

EOF

chown -R www-data:www-data /var/www/html
chmod 755 /var/www/html/index.php
sleep 60
stress --cpu 2 --timeout 300 &
systemctl enable apache2
systemctl restart apache2