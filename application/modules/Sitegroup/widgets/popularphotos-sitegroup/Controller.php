<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitegroup
 * @copyright  Copyright 2010-2011 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Controller.php 2011-05-05 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Sitegroup_Widget_PopularphotosSitegroupController extends Engine_Content_Widget_Abstract {

	//ACTION FOR GETTING THE MOST POPULAR PHOTOS
  public function indexAction() {

   	//HERE WE CHECKING THE SITEGROUP ALBUM IS ENABLED OR NOT
		$sitegroupalbumEnabled = Engine_Api::_()->getDbtable('modules', 'core')->isModuleEnabled('sitegroupalbum');
		if (!$sitegroupalbumEnabled) {
			return $this->setNoRender();
		}

    //SEARCH PARAMETER
    $params = array();
		$params['orderby'] = 'view_count DESC';
		$params['zero_count'] = 'view_count';
    $params['limit'] = $this->_getParam('itemCount', 4);
    $this->view->displayGroupName = $this->_getParam('showGroupName', 0);
    $this->view->displayUserName = $this->_getParam('showUserName', 0);
    $this->view->showFullPhoto = $this->_getParam('showFullPhoto', 0);
    $params['category_id'] = $this->_getParam('category_id',0);
    $photoTable = Engine_Api::_()->getDbtable('photos', 'sitegroup');
		$this->view->paginator = $paginator = $photoTable->widgetPhotos($params);

    if (Count($paginator) <= 0) {
      return $this->setNoRender();
    }
    $this->view->count =  $photoTable->countTotalPhotos($params);
    //SHOWS PHOTOS IN THE LIGHTBOX
    //$this->view->showLightBox = Engine_Api::_()->sitegroup()->canShowPhotoLightBox();
  }

}

?>