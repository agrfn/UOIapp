<?php


//connect to the database
include 'createConnect.php';

$Name = $_POST["Name"];
$table = $_POST["table"];

//this deletes a student
$sql = "DELETE FROM $table WHERE name='$Name'";

// Check if there are results
if ($con->query($sql) === TRUE){
	echo "Record deleted successfully";
}else{
	echo "Error: " . $sql . "<br>" . $con->error;
}

//close connection
include 'closeConnect.php';
?>