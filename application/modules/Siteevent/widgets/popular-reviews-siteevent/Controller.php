<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Siteevent
 * @copyright  Copyright 2013-2014 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Controller.php 6590 2014-01-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Siteevent_Widget_PopularReviewsSiteeventController extends Engine_Content_Widget_Abstract {

    public function indexAction() {

        //FETCH REVIEW DATA
        $params = array();
        $this->view->popularity = $params['popularity'] = $this->_getParam('popularity', 'view_count');
        $params['limit'] = $this->_getParam('itemCount', 3);
        $this->view->type = $params['type'] = $this->_getParam('type', 'user');
        $this->view->status = $params['status'] = $this->_getParam('status', 0);
        $params['interval'] = $interval = $this->_getParam('interval', 'overall');
        $params['groupby'] = $this->_getParam('groupby', 1);
        $this->view->title_truncation = $this->_getParam('truncation', 16);
        $params['resource_type'] = 'siteevent_event';
        $this->view->statistics = $this->_getParam('statistics', array("likeCount", "commentCount"));

        //IF SOME REVIEW TYPE IS NOT ALLOWED
        if (!Engine_Api::_()->getApi('settings', 'core')->getSetting('siteevent.reviews', 2) || (Engine_Api::_()->getApi('settings', 'core')->getSetting('siteevent.reviews', 2) == 2 && $this->view->type == 'editor') || (Engine_Api::_()->getApi('settings', 'core')->getSetting('siteevent.reviews', 2) == 1 && $this->view->type == 'user')) {
            return $this->setNoRender();
        }

        //GET REVIEWS
        $this->view->reviews = Engine_Api::_()->getDbtable('reviews', 'siteevent')->getReviews($params);

        //DON'T RENDER IF NO DATA FOUND
        if ((Count($this->view->reviews) <= 0)) {
            return $this->setNoRender();
        }
    }

}
