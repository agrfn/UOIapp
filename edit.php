<?php


//connect to the database
include 'createConnect.php';

$Name = $_POST["Name"];
$Time = $_POST["Time"];
$table = $_POST["table"];

//this updates a students time
$sql = "UPDATE $table SET Time='$Time' WHERE Name='$Name'";

// Check if there are results
if ($con->query($sql) === TRUE){
	echo "New record created successfully";
}else{
	echo "Error: " . $sql . "<br>" . $con->error;
}

//close connection
include 'closeConnect.php';
?>