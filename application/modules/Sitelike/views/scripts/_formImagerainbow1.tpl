<?php 
 /**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitelike
 * @copyright  Copyright 2009-2010 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: _formImagerainbow1.tpl 6590 2010-11-04 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<?php 
	$this->headScript()->appendFile($this->layout()->staticBaseUrl . 'application/modules/Sitelike/externals/scripts/mooRainbow.js');
	
  $this->headLink()->appendStylesheet($this->layout()->staticBaseUrl . 'application/modules/Sitelike/externals/styles/mooRainbow.css'); 
?> 
<script type="text/javascript">
	window.addEvent('domready', function() { 
		var r = new MooRainbow('myRainbow1', { 
			id: 'myDemo1',
			'startColor': [58, 142, 246],
			'onChange': function(color) {
				$('like_background_color').value = color.hex;
			}
		});
	});	
</script>
	<div id="like_background_color-wrapper" class="form-wrapper">
		<div id="like_background_color-label" class="form-label">
			<label for="like_background_color" class="optional">
				<?php echo $this->translate('Like Button Background');?>
			</label>
		</div>
		<div id="like_background_color-element" class="form-element">
			<p class="description"><?php echo $this->translate('Select the background color of the Like button. (Click on the rainbow below to choose your color.)')?></p>
			<input name="like_background_color" id="like_background_color" value="<?php echo Engine_Api::_()->getApi('settings', 'core')->getSetting('like.background.color', '#f1f2f1')?>" type="text">
			<input name="myRainbow1" id="myRainbow1" src="<?php echo $this->layout()->staticBaseUrl ?>application/modules/Sitelike/externals/images/rainbow.png" link="true" type="image">
		</div>
	</div>
