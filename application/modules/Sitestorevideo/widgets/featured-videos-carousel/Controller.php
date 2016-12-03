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

class Sitestorevideo_Widget_FeaturedVideosCarouselController extends Engine_Content_Widget_Abstract {

  public function indexAction() {
    //SEARCH PARAMETER
    $params = array();
    $params['zero_count'] = 'featured';
    $this->view->category_id = $params['category_id'] = $this->_getParam('category_id',0);
    $this->view->featuredVideos = $featuredVideos = Engine_Api::_()->getDbTable('videos', 'sitestorevideo')->widgetVideosData($params);
    $this->view->totalCount_video = count($featuredVideos);
    if (!($this->view->totalCount_video > 0)) {
      return $this->setNoRender();
    }

    $this->view->inOneRow_video = $inOneRow = $this->_getParam('inOneRow', 3);
    $this->view->noOfRow_video = $noOfRow = $this->_getParam('noOfRow', 2);
    $this->view->totalItemShowvideo = $totalItemShow = $inOneRow * $noOfRow;
    $params['limit'] = $totalItemShow;
    // List List featured
    $this->view->featuredVideos = $this->view->featuredVideos = $featuredVideos = Engine_Api::_()->getDbTable('videos', 'sitestorevideo')->widgetVideosData($params);

    // CAROUSEL SETTINGS  
    $this->view->interval = $interval = $this->_getParam('interval', 250);
    $this->view->count = $count = $featuredVideos->count();
    $this->view->heightRow = @ceil($count / $inOneRow);
    $this->view->vertical = $this->_getParam('vertical', 0);
  }

}