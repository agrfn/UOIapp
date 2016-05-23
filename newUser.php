<?php


//connect to the database
include 'createConnect.php';

$userName = $_POST["UserName"];

// This SQL statement selects ALL from the table 'Students'
/*$sql = "CREATE TABLE `$userName` (
Name varchar(100), 
StudentEmail varchar(100), 
ParentEmail varchar(100),
Time varchar(4)
)";*/
$sql = "CREATE TABLE `$userName` (
Name varchar(100), 
Time varchar(4)
)";

if ($result = mysqli_query($con, $sql))
{
	echo ("table created successfully");
}

//close connection
include 'closeConnect.php';
?>