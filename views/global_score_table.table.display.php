<?php
if(!isset($lang)){
	include('./languages/language.php');
}
$res = "<table class='table table-hover sortable' id='GlobScore'>
	<thead>
		<tr>
			<th>".$lang['classement']."</th>
			<th>".$lang['userName']."</th>
			<th>".$lang['score_global']."</th>
			<th>".$lang['score_oracle']."</th>
			<th>".$lang['score_druid']."</th>
			<th>".$lang['score_diviner']."</th>
			<th>".$lang['listLangues']."</th>
		</tr>
	</thead>
	<tbody>";
		foreach($scoreTable->the_scores as $score){
			$res .= $score."\n";
		}
	$res .= '</tbody>
</table>';
?>
