<html>
<head>
<meta name="google" content="notranslate">
<style>
	body {
		background-color: #78228822;
		font-family: sans-serif;
		font-weight: normal;
	}
	.article {
		border: 1px solid lightgray;
		margin: 8px;
		padding: 8px;
		width: 500px;
		display: inline-block;
	}
	.title {
		font-size: 16px;
		font-variant: small-caps;
		font-weight: bold;
	}
	.date {
		font-size: 12px;
		font-weight: lighter;
	}
	.by {
		font-size: 14px;
		font-weight: lighter;
	}
	.content {
		font-size: 15px;
	}
</style>
</head>
<body>
<?php

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