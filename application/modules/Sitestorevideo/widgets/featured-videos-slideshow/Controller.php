<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitestorevideo
 * @copyright  Copyright 2012-2013 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Controller.php 2013-09-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Sitestorevideo_Widget_FeaturedVideosSlideshowController extends Engine_Content_Widget_Abstract {

  public function indexAction() {
    
    //SEARCH PARAMETER
    $params = array();
    $params['zero_count'] = 'featured';
    $params['category_id'] = $this->_getParam('category_id',0);
    $params['limit'] = $this->_getParam('itemCountPerStore', 10);
   
    $this->view->show_slideshow_object = $this->view->featuredVideos = $featuredVideos = Engine_Api::_()->getDbTable('videos', 'sitestorevideo')->widgetVideosData($params);

    // Count Featured Videos
    $this->view->num_of_slideshow = count($featuredVideos);
    // Number of the result.
    if (empty($this->view->num_of_slideshow)) {
      return $this->setNoRender();
    }
  }

}
?>