<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitevideo
 * @copyright  Copyright 2015-2016 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Controller.php 6590 2016-3-3 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Sitevideo_Widget_UploadVideoSitevideoController extends Engine_Content_Widget_Abstract {

    public function indexAction() {

        // Must be logged in
        $viewer = Engine_Api::_()->user()->getViewer();
        if (!$viewer || !$viewer->getIdentity()) {
            return $this->setNoRender();
        }

        // Must be able to create videos
        if (!Engine_Api::_()->authorization()->isAllowed('video', $viewer, 'create')) {
            return $this->setNoRender();
        }
        
        $sitevideoVideosList = Zend_Registry::isRegistered('sitevideoVideosList') ? Zend_Registry::get('sitevideoVideosList') : null;
        if(empty($sitevideoVideosList))
            return $this->setNoRender();

        $this->view->upload_button = $this->_getParam('upload_button', 0);
        $this->view->upload_button_title = $this->_getParam('upload_button_title', 'Post New Video');
    }

}
