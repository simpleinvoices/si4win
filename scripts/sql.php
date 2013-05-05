<?php
$host=$_GET['d1'];
$user=$_GET['d2'];
$pass=$_GET['d3'];
$name=$_GET['d4']; 
$tables = "si_customers,si_custom_fields,si_index,si_inventory,si_invoices,si_invoice_items,si_invoice_type,si_payment,si_invoice_item_tax,si_payment_types,si_preferences,si_products,si_tax,si_user_domain,si_user_role";

if($_GET['q']=="get"){
	$link = mysql_connect($host,$user,$pass);
	mysql_select_db($name,$link);

	//get all of the tables
	if($tables == '*')
	{
		$tables = array();
		$result = mysql_query('SHOW TABLES');
		while($row = mysql_fetch_row($result))
		{
			$tables[] = $row[0];
		}
	}
	else
	{
		$tables = is_array($tables) ? $tables : explode(',',$tables);
	}

	$return="";

	//cycle through
	foreach($tables as $table)
	{
		$result = mysql_query('SELECT * FROM '.$table);
		$num_fields = mysql_num_fields($result);
		
		$return.= 'DROP TABLE '.$table.';';
		$row2 = mysql_fetch_row(mysql_query('SHOW CREATE TABLE '.$table));
		$return.= "\n\n".$row2[1].";\n\n";
		
		for ($i = 0; $i < $num_fields; $i++) 
		{
			while($row = mysql_fetch_row($result))
			{
				$return.= 'INSERT INTO '.$table.' VALUES(';
				for($j=0; $j<$num_fields; $j++) 
				{
					//$row[$j] = addslashes($row[$j]);
					//$row[$j] = strip_tags($row[$j] );
					$row[$j] = mysql_real_escape_string($row[$j]);
					$row[$j] = ereg_replace("\n","\\n",$row[$j]);
					
					if (isset($row[$j])) { $return.= '"'.$row[$j].'"' ; } else { $return.= '""'; }
					if ($j<($num_fields-1)) { $return.= ','; }
				}
				$return.= ");\n";
			}
		}
		$return.="\n\n\n";
	}

	//save file
	//$BackupFile='db-backup-'.time().'-'.(md5(implode(',',$tables))).'.sql';
	//$handle = fopen($BackupFile,'w+');
	//fwrite($handle,$return);
	//fclose($handle);
	//echo $BackupFile;

	$data=$return;
	$file_temp = "php://temp/";	
	$file_new=fopen($file_temp, 'r+b');
	fwrite($file_new,$data);
	$file_name=$BackupFile;

	rewind($file_new);
	header('Content-Description: File Transfer');
	header('Content-Type: application/octet-stream');
	header('Content-Disposition: attachment; filename='.basename($file_name));
	header('Content-Transfer-Encoding: binary');
	header('Expires: 0');
	header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
	header('Pragma: public');
	header('Content-Length: ' . mb_strlen($data));
		
	ob_clean();
	flush();
	rewind($file_new);
	echo stream_get_contents($file_new);
	fclose($file_new);

}elseif($_GET['q']=="set"){	
	$link = mysql_connect($host,$user,$pass);
	mysql_select_db($name,$link) or die('Error selecting MySQL database: ' . mysql_error());
	
	
	if(isset($_POST["data"])) {
		$lines=explode("\n",$_POST["data"]);		
		
		// Temporary variable, used to store current query
		$templine = '';
		
		// Loop through each line
		foreach ($lines as $line)
		{
			// Skip it if it's a comment
			if (substr($line, 0, 2) == '--' || $line == '')
				continue;
		 
			// Add this line to the current segment
			$templine .= $line;
			// If it has a semicolon at the end, it's the end of the query
			if (substr(trim($line), -1, 1) == ';')
			{
				// Perform the query
				mysql_query($templine);// or print('Error performing query \'<strong>' . $templine . '\': ' . mysql_error() . '<br /><br />');
				echo $templine."\n\n";
				// Reset temp variable to empty
				$templine = '';
			}
		}


	}else{
		?>
		<html>
		<body>

		<form action="sql.php?q=set&<? echo "d1=".$host."&d2=".$user."&d3=".$pass."&d4=".$name   ?>" method="post" name="sqlform">
		<textarea rows="40" cols="90" name="data" />
		<input type="submit" />
		</form>

		</body>
		</html>
		<?
	}

}else{
	header("HTTP/1.0 404 Not Found");
}

?> 