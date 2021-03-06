<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitestore
 * @copyright  Copyright 2012-2013 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Controller.php 2013-09-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Sitestore_Widget_ProfileSitestoreController extends Seaocore_Content_Widget_Abstract {

  protected $_childCount;

  public function indexAction() {

    //DONT RENDER IF NOT AUTHORIZED
    if (!Engine_Api::_()->core()->hasSubject()) {
      return $this->setNoRender();
    }

		//GET VIEWER
		$viewer = Engine_Api::_()->user()->getViewer();

    //GET SUBJECT AND CHECK AUTHENTICATION
    $subject = Engine_Api::_()->core()->getSubject();
    if (!$subject->authorization()->isAllowed($viewer, 'view')) {
      return $this->setNoRender();
    }

		$values = array();
    $this->view->is_ajax = $is_ajax = $this->_getParam('isajax', '');
    $this->view->category_id =  $values['category_id'] = $this->_getParam('category_id',0);
    if( $is_ajax ) {
      $this->getElement()->removeDecorator('Title');
      $this->getElement()->removeDecorator('Container');
    }
    $this->view->storeAdmin = $this->_getParam('storeAdmin', 1);
		if($this->_getParam('storeAdmin', 1) == 2) {

			//GET STORES
			$adminstores = Engine_Api::_()->getDbtable('manageadmins', 'sitestore')->getManageAdminStores($subject->getIdentity());

			//GET STUFF
			$ids = array();
			foreach ($adminstores as $adminstore) {
				$ids[] = $adminstore->store_id;
			}
			$values['adminstores'] = $ids;
		}
		else {
			$values['user_id'] = $subject->getIdentity();
		}

		$values['type'] = 'browse';
		$values['orderby'] = 'creation_date';
		$values['type_location'] = 'manage';
// 		if (Engine_Api::_()->getDbtable( 'modules' , 'core' )->isModuleEnabled('sitestoremember'))  {
// 			$values['type_location'] = 'profilebrowseStore';
//     }
    $this->view->paginator = $paginator = Engine_Api::_()->sitestore()->getSitestoresPaginator($values);


    $this->view->paginator->setCurrentPagenumber(1);
    $paginator->setItemCountPerPage(10);
    $paginator->setCurrentPageNumber($this->_getParam('store', 1));

    //DONT RENDER IF NOTHING TO SHOW
    if ($paginator->getTotalItemCount() <= 0) {
      return $this->setNoRender();
    }

    //ADD COUNT IF CONFIGURED
    if ($this->_getParam('titleCount', false) && $paginator->getTotalItemCount() > 0) {
      $this->_childCount = $paginator->getTotalItemCount();
    }

    //STORE-RATING IS ENABLE OR NOT
    $this->view->ratngShow = (int) Engine_Api::_()->getDbtable('modules', 'core')->isModuleEnabled('sitestorereview');
  }

  public function getChildCount() {
    return $this->_childCount;
  }

}
?>