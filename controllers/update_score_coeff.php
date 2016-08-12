<?php

	function selectScoreSql($sql) {
		require_once("./sys/db.class.php");
		$db = db::getInstance();
		$result=$db->query($sql);
		return mysqli_fetch_array($result,MYSQLI_NUM);	// tableau num�rique
	}

	function getCardLvlPts($enregistrement_id) {
		require_once("./sys/db.class.php");
		$db = db::getInstance();
		$sql = 'SELECT nivcarte FROM enregistrement WHERE enregistrementID="' . $enregistrement_id . '"';
		$niv = mysqli_fetch_array($db->query($sql),MYSQLI_NUM);
		$niv = $niv[0]{0};
		if ($niv=="A") { $lvl = "easy"; }
		else if ($niv=="B") { $lvl = "medium"; }
		else if ($niv == "C") { $lvl = "hard"; }
		else { $lvl = 'easy'; }
		$sql = 'SELECT points FROM game_lvl WHERE userlvl="' . $lvl . '"';
		$lvl_pts = mysqli_fetch_array($db->query($sql),MYSQLI_NUM);
		return $lvl_pts[0];
	}

	function getLangLvlPts($id,$lang) {
		error_reporting(E_ALL & ~E_NOTICE);
		require_once("./sys/db.class.php");
		$db = db::getInstance();
		$sql = 'SELECT * FROM user_niveau WHERE userid="' . $id . '"';
		$result = $db->query($sql);
		$res= mysqli_fetch_assoc($result);
		$spoken_lang = explode(';',$res['spoken_lang']);
		$lvl = explode(';',$res['niveau']);
		$i=0;
		while ($i < count($spoken_lang) && strcmp($lang,$spoken_lang[$i]) != 0) {
			$i++;
		}
		$sql = 'SELECT * FROM coeff_niveau_langue WHERE niveau_langue="' . $lvl[$i] . '"';
		$result = $db->query($sql);
		$coef = mysqli_fetch_assoc($result)['coeff'];
		if($coef ==""){
			$coef = 1; //Dans le cas o� l'utilisateur joue en devin dans une nouvelle langue... par d�faut 1
		}
		return $coef;
	}

	function gagneScore($lvl_pts,$lang_lvl_pts) {
		return $lvl_pts*$lang_lvl_pts;
	}

	function perdScore($lvl_pts,$lang_lvl_pts) {
		return -$lvl_pts*$lang_lvl_pts/2;
	}

	function computeScore($sql,$id,$lang,$lvl_pts,$gagne) {
		$res = selectScoreSql($sql);
//~ 		$scoreGlobal = $res['scoreGlobal'];
//~ 		$scoreRole = $res['scoreOracle'];
		$scoreGlobal = $res[0];
		$scoreRole = $res[1];
		$firstGameTime = $res[2];
		$lang_lvl_pts = getLangLvlPts($id, $lang);


		if ($gagne) {
			$diffScore = gagneScore($lvl_pts,$lang_lvl_pts);
		} else {
			$diffScore = perdScore($lvl_pts,$lang_lvl_pts);
		}


		$scoreGlobal= $scoreGlobal+$diffScore;
		$scoreRole = $scoreRole+$diffScore;
		if (strlen($firstGameTime) == 0) {
			$firstGameTime = date("d/m/Y H:i:s");
		}
		return array($scoreGlobal,$scoreRole,$firstGameTime);
	}

	function updateScoreDevinSucces($id,$lang,$lvl_pts) {
		require_once("./sys/db.class.php");
		$db = db::getInstance();
		$sql = 'SELECT scoreGlobal,scoreDevin,first_game_time FROM score WHERE userid="'.$id.'" AND langue="'. $lang .'"';
		$scores = computeScore($sql,$id,$lang,$lvl_pts,true);
		//print_r($scores);
		$sql = 'UPDATE score
				SET  scoreGlobal='.$db->escape((string) $scores[0]) . ', ' .
				'scoreDevin='.$db->escape((string) $scores[1]) . ', ' .
				'first_game_time=' . $db->escape((string) $scores[2]) .'
				WHERE userid='.$id.' AND langue= "'.$lang.'"';
		$db->query($sql);
	}

	function updateScoreDruideCreation($id,$lang,$lvl_pts) {
		require_once("./sys/db.class.php");
		$db = db::getInstance();
		$sql = 'SELECT scoreGlobal,scoreDruide,first_game_time FROM score WHERE userid="'.$id.'" AND langue="'. $lang .'"';
		$res = selectScoreSql($sql);
		$scoreGlobal = $res[0];
		$scoreRole = $res[1];
		$firstGameTime = $res[2];
		if (strlen($firstGameTime) == 0) {
			$firstGameTime = date("d/m/Y H:i:s");
		}
		$scoreGlobal= $scoreGlobal+(10);
		$scoreRole = $scoreRole+(10);
		$sql = 'UPDATE score
				SET  scoreGlobal='.$db->escape((string) $scoreGlobal) . ', ' .
				'scoreDruide='.$db->escape((string) $scoreRole) . ', ' .
				'first_game_time=' . $db->escape((string) $firstGameTime) .'
				WHERE userid='.$id.' AND langue= "'.$lang.'"';
		$db->query($sql);
	}

	function updateScoreDruideArbitrage($id,$lang,$lvl_pts) {
		updateScoreDruideCreation($id,$lang,$lvl_pts);
	}

	function updateScoreOracleDevinSucces($id,$lang,$enregistrement_id) {
		updateScoreOracleDruideAccepte($id,$lang,$enregistrement_id);
//~ 		require_once("./sys/db.class.php");
//~ 		$db = db::getInstance();
//~ 		$sql = 'SELECT scoreGlobal,scoreOracle,first_game_time FROM score WHERE userid="'.$id.'" AND langue="'. $lang .'"';
//~ 		$scores = computeScore($sql,$id,$lang,$lvl_pts,true);
//~ 		$sql = 'UPDATE score
//~ 				SET  scoreGlobal='.$db->escape((string) $scores[0]) . ', ' .
//~ 				'scoreOracle='.$db->escape((string) $scores[1]) . ', ' .
//~ 				'first_game_time=' . $db->escape((string) $scores[2]) .'
//~ 				WHERE userid='.$id.' AND langue= "'.$lang.'"';
//~ 		$db->query($sql);
	}

	function updateScoreOracleDruideAccepte($id,$lang,$enregistrement_id) {
//~ 		updateScoreOracleDevinSucces($id,$lang,$lvl_pts);

		require_once("./sys/db.class.php");
		$db = db::getInstance();

		$lvl_pts = getCardLvlPts($enregistrement_id);

		$sql = 'SELECT scoreGlobal,scoreOracle,first_game_time FROM score WHERE userid="'.$id.'" AND langue="'. $lang .'"';
		$scores = computeScore($sql,$id,$lang,$lvl_pts,true);
		$sql = 'UPDATE score
				SET  scoreGlobal='.$db->escape((string) $scores[0]) . ', ' .
				'scoreOracle='.$db->escape((string) $scores[1]) . ', ' .
				'first_game_time=' . $db->escape((string) $scores[2]) .'
				WHERE userid='.$id.' AND langue= "'.$lang.'"';
		$db->query($sql);
	}

	function updateScoreOracleDevinEchec($id,$lang,$enregistrement_id) {
		updateScoreOracleDruideRefuse($id,$lang,$enregistrement_id);
//~ 		require_once("./sys/db.class.php");
//~ 		$db = db::getInstance();
//~ 		$sql = 'SELECT scoreGlobal,scoreOracle,first_game_time FROM score WHERE userid="'.$id.'" AND langue="'. $lang .'"';
//~ 		$scores = computeScore($sql,$id,$lang,$lvl_pts,false);
//~ 		$sql = 'UPDATE score
//~ 				SET  scoreGlobal='.$db->escape((string) $scores[0]) . ', ' .
//~ 				'scoreOracle='.$db->escape((string) $scores[1]) . ', ' .
//~ 				'first_game_time=' . $db->escape((string) $scores[2]) .'
//~ 				WHERE userid='.$id.' AND langue= "'.$lang.'"';
//~ 		$db->query($sql);
	}

	function updateScoreOracleDruideRefuse($id,$lang,$enregistrement_id) {
//~ 		updateScoreOracleDevinEchec($id,$lang,$lvl_pts);

		require_once("./sys/db.class.php");
		$db = db::getInstance();

//~ 		$sql = 'SELECT nivcarte FROM enregistrement WHERE enregistrementID="' . $enregistrement_id . '"';
//~ 		$res = mysqli_fetch_array($db->query($sql),MYSQLI_NUM);
//~ 		if (strcmp($res[0],"facile") == 0) { $lvl = "easy"; }
//~ 		else if (strcmp($res[0],"moyen") == 0) { $lvl = "medium"; }
//~ 		else if (strcmp($res[0],"difficile") == 0) { $lvl = "hard"; }
//~ 		$sql = 'SELECT points FROM game_lvl WHERE userlvl="' . $lvl . '"';
//~ 		$lvl_pts = mysqli_fetch_array($db->query($sql),MYSQLI_NUM);

		$lvl_pts = getCardLvlPts($enregistrement_id);

		$sql = 'SELECT scoreGlobal,scoreOracle,first_game_time FROM score WHERE userid="'.$id.'" AND langue="'. $lang .'"';
		$scores = computeScore($sql,$id,$lang,$lvl_pts,false);
		if ($scores[0] >= 0 && $scores[1] >= 0) {
			$sql = 'UPDATE score
					SET  scoreGlobal='.$db->escape((string) $scores[0]) . ', ' .
					'scoreOracle='.$db->escape((string) $scores[1]) . ', ' .
					'first_game_time=' . $db->escape((string) $scores[2]) .'
					WHERE userid='.$id.' AND langue= "'.$lang.'"';
			$db->query($sql);
	}
	}


//A class to handle the main rules
//This is as disgusting as it gets (why isn't this in the controllers folder ? for a start), it will encapsulate in one class utilities that should be split in separate classes, but considering the rest of the program, this might be safer…
require_once('./sys/constants.php');
require_once('./models/user.class.php');
require_once('./sys/db.class.php');//useless (called by Card)

class GameHandler{
	const LVL_EASY = 0;
	const LVL_MEDIUM = 1;
	const LVL_HARD = 2;
	const LVL_HARDEST = 3;
	const ACT_CREATECARD = 5;
	const ACT_VERIFYRECORD = 6;
	private static $MULTIPLIERS = array(2 => 2, 1 => 1.5, 0 => 1, -1 => 0.7, -2 => 0.5, -3 => 0.33);

	//utilities
	//To unify the way levels are defined throughout the game
	public function unify_Lvl($level){
		switch($level){
			case 'easy':
			case 'A1':
			case 'A2':
			case 'Débutant':
				$res = self::LVL_EASY;
				break;
			case 'medium':
			case 'B1':
			case 'B2':
			case 'Intermédiaire':
				$res = self::LVL_MEDIUM;
				break;
			case 'hard':
			case 'C1':
			case 'Avancé':
				$res = self::LVL_HARD;
				break;
			case 'Natif':
			case 'C2':
				$res = self::LVL_HARDEST;
				break;
			default:
				$res = false;
		}
		return $res;
	}

	function get_mastery_mult($card_lvl, $user_lvl){
		if(!is_int($card_lvl)){
			$card_lvl = $this->unify_Lvl($card_lvl);
		}
		if(!is_int($user_lvl)){
			$user_lvl = $this->unify_Lvl($user_lvl);
		}
		echo "<p>".($card_lvl - $user_lvl)." → ".self::$MULTIPLIERS[$card_lvl - $user_lvl]."</p>";
		return self::$MULTIPLIERS[$card_lvl - $user_lvl];
	}
}

?>
