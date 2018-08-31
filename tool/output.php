<?php

echo "start\n";

ini_set('memory_limit', '512M');

$pdo = new PDO('mysql:host=192.168.101.3;dbname=isubata', 'isucon', 'isucon');
foreach($pdo->query('select name, data from image group by name, data;') as $row) {
    $filename = $row['name'];
    $data = $row['data'];

    try {
        if (!file_exists($filename)) {
            $fp = fopen($filename, 'wb');
            fwrite($fp, $data);
            fclose($fp);
            echo "output: {$filename}\n";
        }
    } catch (Exception $e) {
        echo "failed: {$filename}";
    }
}

echo "done\n";
