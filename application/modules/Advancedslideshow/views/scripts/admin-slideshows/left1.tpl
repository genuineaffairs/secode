<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Advancedslideshow
 * @copyright  Copyright 2010-2011 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: left1.tpl 2011-10-22 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<style type="text/css">
.slideshow-thumbnailsleft1{
	width:<?php echo $this->width ?>px;
}
.slideshow-thumbnailsleft1 ul {
	background: <?php echo $this->thumb_back_color ?>;
}
.slideshow-thumbnailsleft1-active {
	background-color: <?php echo $this->thumb_bord_color ?>;
	opacity: 1;
}
.slideshow-thumbnailsleft1-inactive {
	background-color: 	<?php echo $this->thumb_bord_active ?>;
	opacity: .5;
}
.slideshow-thumbnailsleft1 img {
	width: <?php  $temp_width_s = ($this->thumb_width > 90) ?  $this->thumb_width : 91; echo $temp_width_s - 10;  ?>px;
}
</style>