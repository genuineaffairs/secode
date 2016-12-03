<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitemailtemplates
 * @copyright  Copyright 2011-2012 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: _formImagerainbowHeader.tpl 6590 2012-06-20 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>

<?php 
	$template_id = Zend_Controller_Front::getInstance()->getRequest()->getParam('template_id', null);
	$action = Zend_Controller_Front::getInstance()->getRequest()->getActionName();
  $header_bgcolor = '#79b4d4';

	if($action == 'edit' && is_numeric($template_id)) {
		$sitemailtemplates = Engine_Api::_()->getItem('sitemailtemplates_templates', $template_id);
		if(!empty($sitemailtemplates->header_bgcol)) {
			$header_bgcolor = $sitemailtemplates->header_bgcol;
		}
	}
?>

<script src="<?php echo $this->layout()->staticBaseUrl ?>application/modules/Seaocore/externals/scripts/mooRainbow.js" type="text/javascript"></script>

<?php
	$this->headLink()
			->prependStylesheet($this->layout()->staticBaseUrl.'application/modules/Seaocore/externals/styles/mooRainbow.css');
?>

<script type="text/javascript">
  function hexcolorTonumbercolor(hexcolor) {
    var hexcolorAlphabets = "0123456789ABCDEF";
    var valueNumber = new Array(3);
    var j = 0;
    if(hexcolor.charAt(0) == "#")
      hexcolor = hexcolor.slice(1);
    hexcolor = hexcolor.toUpperCase();
    for(var i=0;i<6;i+=2) {
      valueNumber[j] = (hexcolorAlphabets.indexOf(hexcolor.charAt(i)) * 16) + hexcolorAlphabets.indexOf(hexcolor.charAt(i+1));
      j++;
    }
    return(valueNumber);
  }
  window.addEvent('domready', function() { 
    var s = new MooRainbow('myRainbow1', { 
      id: 'myDemo1',
      'startColor': hexcolorTonumbercolor('<?php echo $header_bgcolor ?>'),
      'onChange': function(color) {
        $('header_bgcol').value = color.hex;
      }
    });
  });
</script>

<?php

echo '
<div id="header_bgcol-wrapper" class="form-wrapper">
	<div id="header_bgcol-label" class="form-label">
		<label for="header_bgcol" class="optional">
			' . $this->translate('Email Template Header Background Color') . '
		</label>
	</div>
	<div id="header_bgcol-element" class="form-element">
		<p class="description">' . $this->translate('Select the color of the header background of email template. (Click on the rainbow below to choose your color.)') . '</p>
		<input name="header_bgcol" id="header_bgcol" value=' . $header_bgcolor . ' type="text">
		<input name="myRainbow1" id="myRainbow1" src="'. $this->layout()->staticBaseUrl . 'application/modules/Seaocore/externals/images/rainbow.png" link="true" type="image">
	</div>
</div>
'
?>