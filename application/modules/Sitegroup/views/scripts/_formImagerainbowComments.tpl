<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitegroup
 * @copyright  Copyright 2010-2011 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: _formimagerainbowcomments.tpl 2011-05-05 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>

<?php
$this->headScript()->appendFile($this->layout()->staticBaseUrl . 'application/modules/Sitegroup/externals/scripts/mooRainbow.js');
$this->headLink()->appendStylesheet($this->layout()->staticBaseUrl . 'application/modules/Sitegroup/externals/styles/mooRainbow.css');
?>

<script type="text/javascript">
  window.addEvent('domready', function() { 
    var s = new MooRainbow('myRainbow5', { 
      id: 'myDemo5',
      'startColor': hexcolorTonumbercolor("<?php echo Engine_Api::_()->getApi('settings', 'core')->getSetting('sitegroup.graphcomment.color', '#9F5F9F') ?>"),
      'onChange': function(color) {
        $('sitegroup_graphcomment_color').value = color.hex;
      }
    });
  });
</script>

<?php
echo '
 	<div id="sitegroup_graphcomment_color-wrapper" class="form-wrapper">
 		<div id="sitegroup_graphcomment_color-label" class="form-label">
 			<label for="sitegroup_graphcomment_color" class="optional">
 				' . $this->translate('Comments Line Color') . '
 			</label>
 		</div>
 		<div id="sitegroup_graphcomment_color-element" class="form-element">
 			<p class="description">' . $this->translate('Select the color of the line which is used to represent Comments in the graph. (Click on the rainbow below to choose your color.)') . '</p>
 			<input name="sitegroup_graphcomment_color" id="sitegroup_graphcomment_color" value=' . Engine_Api::_()->getApi('settings', 'core')->getSetting('sitegroup.graphcomment.color', '#9F5F9F') . ' type="text">
 			<input name="myRainbow5" id="myRainbow5" src="application/modules/Sitegroup/externals/images/rainbow.png" link="true" type="image">
 		</div>
 	</div>
 '
?>