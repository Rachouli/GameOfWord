<?php
	session_start();
	require_once("../sys/db.class.php");
	if(($_SESSION['userid'] == $_GET['user_id'])
		&& isset($_GET['card_id'])){
		$db = db::getInstance();
		$db->query("UPDATE `cartes` SET `dateSuppression` = CURRENT_TIMESTAMP, `idEraser` = '".$_SESSION['userid']."' WHERE `cartes`.`idCarte` = '".$_GET['card_id']."';");
		if($db->affected_rows() == 1){
			echo "OK";
		}
		else{
			echo $db->affected_rows()." enregistrements affectés (≠1, pourquoi?)";
		}
	}
	else{
		print_r($lang);
		echo $user->id." ≠ ".$_GET['user_id']." : Problème de connexion, vous n'êtes plus vous-même…";
	}
?>
