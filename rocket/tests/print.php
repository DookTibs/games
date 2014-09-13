<?php
	$foo = "is <b>THIS</b> text <a href='#' onClick='javascript:alert(\"hey there\");'>bold</a>?";

	// echo htmlspecialchars($foo);
	echo strip_tags($foo, '<i><b><a>');
?>
