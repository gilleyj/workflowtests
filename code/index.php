<?php

	$_POST = json_decode(file_get_contents('php://input'), true);
	print_r($_POST);

	/*
	$DB_HOST = getenv('DB_HOST');
	$DB_PORT = getenv('DB_PORT');
	$DB_USER = getenv('DB_USER');
	$DB_PASS = getenv('DB_PASS');
	$DB_NAME = getenv('DB_NAME');

	$DB = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);

	if ($DB->connect_error) die("Connection failed: " . $DB->connect_error);

	$sql = "SELECT * FROM posts LEFT JOIN authors ON posts.author_id = authors.id ORDER BY posts.date DESC";
	$result = $DB->query($sql);
	if ($result->num_rows > 0) {
		while($row = $result->fetch_assoc()) {
			$title = $row["title"];
			$date = $row["date"];
			$by = $row["first_name"]. " " . $row["last_name"];
			$content = $row["content"];
			echo "<div class='article'>";
			echo "<span class='date'>".$date."</span><br/>";
			echo "<span class='title'>".$title."</span><br/>";
			echo "<span class='by'>".$by."</span> <br/>";
			echo "<p class='content'>".$content."</p>";
			echo "</div>";
		}
	} else {
		echo "0 results";
	}

	$DB->close();