<?php

//connect to the database
include 'createConnect.php';

$table = $_POST["table"];
$Name = $_POST["Name"];
//$ParentEmail = $_POST["ParentEmail"];
//$StudentEmail = $_POST["StudentEmail"];
$Time = $_POST["Time"];

// This SQL adds an entry to Students
//$sql = "INSERT INTO $table (Name, ParentEmail, StudentEmail, Time) 
//VALUES ('$Name', '$ParentEmail', '$StudentEmail', '$Time')";
$sql = "INSERT INTO $table (Name, Time) 
VALUES ('$Name', '$Time')";

// Check if there are results
if ($con->query($sql) === TRUE){
	echo "New record created successfully";
}else{
	echo "Error: " . $sql . "<br>" . $con->error;
}

//close connection
include 'closeConnect.php';
?>