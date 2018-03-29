<?php
require_once 'dbconfig.php';

class TableRows extends RecursiveIteratorIterator { 
    function __construct($it) { 
        parent::__construct($it, self::LEAVES_ONLY); 
    }

    function current() {
        return "<td style='width:150px;border:1px solid black;'>" . parent::current(). "</td>";
    }

    function beginChildren() { 
        echo "<tr>"; 
    } 

    function endChildren() { 
        echo "</tr>" . "\n";
    } 
} 

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    // 1. set the PDO error mode to exception
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "1. Connected successfully: PDO<br>"; 
	
	// 2. create database
	// drop database first
	$sql = "CREATE DATABASE IF NOT EXISTS testDB";
    //use exec() because no results are returned
    $conn->exec($sql);
    echo "2. Database created successfully<br>";
	
	//3. switch database
	$sql="use testDB";
	$conn->exec($sql);
	echo "3. Switch To<br>";
	$sql="SELECT DATABASE() AS DB, USER() AS USER";
	foreach ($conn->query($sql) as $row) {
        print $row['DB'] . "\t";
        print $row['USER'] . "\n";
	}
	echo "Switch successfully<br>";
	// 4. sql to create table
	$sql = "CREATE TABLE IF NOT EXISTS MyGuests (
	id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
	firstname VARCHAR(30) NOT NULL,
	lastname VARCHAR(30) NOT NULL,
	email VARCHAR(50),
	reg_date TIMESTAMP
	)";

    // use exec() because no results are returned
    $conn->exec($sql);
    echo "4. Table MyGuests created successfully<br>";
	//5. sql insert a record
    $sql = "INSERT INTO MyGuests (firstname, lastname, email)
    VALUES ('John', 'Doe', 'john@example.com')";
    // use exec() because no results are returned
    $conn->exec($sql);
    echo "5. New record created successfully<br>";	
	//6. get the id back
    $sql = "INSERT INTO MyGuests (firstname, lastname, email)
    VALUES ('Logan', 'Henry', 'logan@example.com')";	
    // use exec() because no results are returned
    $conn->exec($sql);
    $last_id = $conn->lastInsertId();
    echo "6. Another record created successfully. Last inserted ID is: " . $last_id. "<br>";
    // 7. Multiple records
	// begin the transaction
    $conn->beginTransaction();
    // our SQL statements
    $conn->exec("INSERT INTO MyGuests (firstname, lastname, email) 
    VALUES ('John', 'Doe', 'john@example.com')");
    $conn->exec("INSERT INTO MyGuests (firstname, lastname, email) 
    VALUES ('Mary', 'Moe', 'mary@example.com')");
    $conn->exec("INSERT INTO MyGuests (firstname, lastname, email) 
    VALUES ('Julie', 'Dooley', 'julie@example.com')");
    // commit the transaction
    $conn->commit();
    echo "7 New records created by transaction successfully<br>";
	
	 // 8. prepare sql and bind parameters
    $stmt = $conn->prepare("INSERT INTO MyGuests (firstname, lastname, email) 
    VALUES (:firstname, :lastname, :email)");
    $stmt->bindParam(':firstname', $firstname);
    $stmt->bindParam(':lastname', $lastname);
    $stmt->bindParam(':email', $email);

    // insert a row
    $firstname = "John";
    $lastname = "Doe";
    $email = "john@example.com";
    $stmt->execute();

    // insert another row
    $firstname = "Mary";
    $lastname = "Moe";
    $email = "mary@example.com";
    $stmt->execute();

    // insert another row
    $firstname = "Julie";
    $lastname = "Dooley";
    $email = "julie@example.com";
    $stmt->execute();

    echo "8. New records created by PREPARE and PARAM BINDING successfully<br>";
	
	// A TableRows  class defined above
	//9. Select * from MyGuests
	echo "9. List records<br>";
	echo "<table style='border: solid 1px black;'>";
	echo "<tr><th>Id</th><th>Firstname</th><th>Lastname</th></tr>";
    $stmt = $conn->prepare("SELECT id, firstname, lastname FROM MyGuests"); 
    $stmt->execute();

    // set the resulting array to associative
    $result = $stmt->setFetchMode(PDO::FETCH_ASSOC); 
    foreach(new TableRows(new RecursiveArrayIterator($stmt->fetchAll())) as $k=>$v) { 
        echo $v;
    }
    }
catch(PDOException $e)
    {
    echo $sql . "<br>" . $e->getMessage();
    }



$conn = null; 
?>