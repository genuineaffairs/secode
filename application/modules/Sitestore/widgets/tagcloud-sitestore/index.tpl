<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitestore
 * @copyright  Copyright 2012-2013 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: index.tpl 2013-09-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<script type="text/javascript">

  var tagAction = function(tag){
    if($('filter_form')) {
       form=document.getElementById('filter_form');
      }else if($('filter_form_tag')){
				form=$('filter_form_tag');
    }   
    form.elements['tag'].value = tag;
    if( $('filter_form'))
    $('filter_form').submit();
		else
		$('filter_form_tag').submit();
  }
</script>

<form id='filter_form_tag' class='global_form_box' method='get' action='<?php echo $this->url(array('action' => 'index'), 'sitestore_general', true) ?>' style='display: none;'>
	<input type="hidden" id="tag" name="tag"  value=""/>
</form>

<h3><?php echo $this->translate('Popular Store Tags'); ?> (<?php echo $this->count_only ?>)</h3>
<ul class="sitestore_sidebar_list">
	<li>
		<?php foreach ($this->tag_array as $key => $frequency): ?>
			<?php $step = $this->tag_data['min_font_size'] + ($frequency - $this->tag_data['min_frequency']) * $this->tag_data['step'] ?>
			<?php ?>
			<a href='javascript:void(0);' onclick='javascript:tagAction(<?php echo $this->tag_id_array[$key]; ?>);' style="float:none;font-size:<?php echo $step ?>px;" title=''><?php echo $key ?><sup><?php echo $frequency ?></sup></a>
		<?php endforeach; ?>
		<br/>
		<b class="explore_tag_link"><?php echo $this->htmlLink(array('route' => 'sitestore_tags', 'action' => 'tagscloud','category_id' => $this->category_id), $this->translate('Explore Tags &raquo;')) ?></b>
	</li>
</ul>