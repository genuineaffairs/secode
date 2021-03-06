<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitealbum
 * @copyright  Copyright 2010-2011 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: index.tpl 2011-08-026 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<?php if( count($this->quickNavigation) > 0 ): ?>
  <div class="quicklinks">
    <?php echo $this->navigation()->menu()->setContainer($this->quickNavigation)->render(); ?>
  </div>
<?php endif; ?>