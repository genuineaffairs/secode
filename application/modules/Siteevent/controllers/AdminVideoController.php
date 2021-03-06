<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Siteevent
 * @copyright  Copyright 2013-2014 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: AdminVideoController.php 6590 2014-01-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Siteevent_AdminVideoController extends Core_Controller_Action_Admin {

    //ACTION FOR MANAGING THE EVENT VIDEOS
    public function manageAction() {

        //GET NAGIGATION
        $this->view->navigation = Engine_Api::_()->getApi('menus', 'core')
                ->getNavigation('siteevent_admin_main', array(), 'siteevent_admin_main_video');

        $this->view->subNavigation = Engine_Api::_()->getApi('menus', 'core')->getNavigation('siteevent_admin_submain', array(), 'siteevent_admin_submain_manage_tab');

        $this->view->enable_video = Engine_Api::_()->getDbtable('modules', 'core')->isModuleEnabled('video');

        //FORM GENERATION
        $this->view->formFilter = $formFilter = new Siteevent_Form_Admin_Manage_Filter();

        //USER TABLE NAME
        $tableUser = Engine_Api::_()->getItemTable('user')->info('name');

        //EVENT TABLE NAME
        $tablesiteevent = Engine_Api::_()->getItemTable('siteevent_event')->info('name');

        //EVENT-VIDEO TABLE
        $table = Engine_Api::_()->getDbtable('videos', 'siteevent');
        $rName = $table->info('name');

        $this->view->type_video = $type_video = Engine_Api::_()->getApi('settings', 'core')->getSetting('siteevent.show.video');
        $videoTable = Engine_Api::_()->getDbTable('clasfvideos', 'siteevent');
        if ($type_video) {

            //VIDEO TABLE NAME
            $videoTableName = $videoTable->info('name');

            //GET CORE VIDEO TABLE
            $coreVideoTable = Engine_Api::_()->getDbtable('videos', 'video');
            $coreVideoTableName = $coreVideoTable->info('name');

            //MAKE QUERY
            $select = $coreVideoTable->select()
                    ->setIntegrityCheck(false)
                    ->from($coreVideoTableName)
                    ->join($videoTableName, $coreVideoTableName . '.video_id = ' . $videoTableName . '.video_id', array())
                    ->join($tablesiteevent, "$videoTableName.event_id = $tablesiteevent.event_id", array('title AS siteevent_title', 'event_id'))
                    ->join($tableUser, "$coreVideoTableName.owner_id = $tableUser.user_id", 'displayname')
                    ->group($coreVideoTableName . '.video_id');
        } else {
            //MAKE QUERY
            $select = $table->select()
                    ->setIntegrityCheck(false)
                    ->from($rName)
                    ->joinLeft($tableUser, "$rName.owner_id = $tableUser.user_id", 'displayname')
                    ->joinLeft($tablesiteevent, "$rName.event_id = $tablesiteevent.event_id", 'title AS siteevent_title');
        }


        $values = array();
        if ($formFilter->isValid($this->_getAllParams())) {
            $values = $formFilter->getValues();
        }

        foreach ($values as $key => $value) {
            if (null === $value) {
                unset($values[$key]);
            }
        }

        $values = array_merge(array(
            'order' => 'video_id',
            'order_direction' => 'DESC',
                ), $values);

        $this->view->assign($values);
        $select->order((!empty($values['order']) ? $values['order'] : 'video_id' ) . ' ' . (!empty($values['order_direction']) ? $values['order_direction'] : 'DESC' ));

        $event = $this->_getParam('event', 1);
        $this->view->paginator = array();
        $this->view->paginator = $paginator = Zend_Paginator::factory($select);
        $this->view->paginator->setItemCountPerPage(50);
        $this->view->paginator = $paginator->setCurrentPageNumber($event);
    }

    //ACTION FOR MULTI-VIDEO DELETE
    public function deleteSelectedAction() {

        //GET VIDEO IDS
        $this->view->ids = $ids = $this->_getParam('ids', null);

        //COUNT IDS
        $ids_array = explode(",", $ids);
        $this->view->count = count($ids_array);

        if ($this->getRequest()->isPost()) {
            $values = $this->getRequest()->getPost();
            foreach ($values as $key => $value) {
                $video_id = (int) $value;
                $type_video = Engine_Api::_()->getApi('settings', 'core')->getSetting('siteevent.show.video');
                if ($type_video) {
                    $clasfVideoTable = Engine_Api::_()->getDbtable('clasfvideos', 'siteevent');
                    $selectClasfvideoTable = $clasfVideoTable->select()
                            ->where('video_id =?', $video_id);
                    $objectClasfvideo = $clasfVideoTable->fetchRow($selectClasfvideoTable);
                    if ($objectClasfvideo) {
                        //FINALLY DELETE VIDEO OBJECT
                        $objectClasfvideo->delete();
                    }
                } else {
                    //GET EVENT VIDEO OBJECT
                    $siteevent = Engine_Api::_()->getItem('siteevent_video', $video_id);

                    if ($siteevent) {

                        //DELETE RATING DATA
                        Engine_Api::_()->getDbtable('videoratings', 'siteevent')->delete(array('videorating_id =?' => $video_id));

                        //FINALLY DELETE VIDEO OBJECT
                        $siteevent->delete();
                    }
                }
            }
            $this->_helper->redirector->gotoRoute(array('action' => 'manage'));
        }
    }

    //ACTION FOR DELETE THE EVENT-VIDEO
    public function deleteAction() {

        //DEFAULT LAYOUT
        $this->_helper->layout->setLayout('admin-simple');

        //GET VIDEO ID
        $this->view->video_id = $video_id = $this->_getParam('video_id');

        if ($this->getRequest()->isPost()) {

            $db = Engine_Db_Table::getDefaultAdapter();
            $db->beginTransaction();
            try {

                $type_video = Engine_Api::_()->getApi('settings', 'core')->getSetting('siteevent.show.video');
                if ($type_video) {
                    $clasfVideoTable = Engine_Api::_()->getDbtable('clasfvideos', 'siteevent');
                    $selectClasfvideoTable = $clasfVideoTable->select()
                            ->where('video_id =?', $video_id);
                    $objectClasfvideo = $clasfVideoTable->fetchRow($selectClasfvideoTable);
                    if ($objectClasfvideo) {
                        //FINALLY DELETE VIDEO OBJECT
                        $objectClasfvideo->delete();
                    }
                } else {

                    //GET EVENT VIDEO OBJECT
                    $siteevent = Engine_Api::_()->getItem('siteevent_video', $video_id);

                    //DELETE RATING DATA
                    Engine_Api::_()->getDbtable('videoratings', 'siteevent')->delete(array('videorating_id =?' => $video_id));

                    //FINALLY DELETE VIDEO OBJECT
                    $siteevent->delete();
                }
                $db->commit();
            } catch (Exception $e) {
                $db->rollBack();
                throw $e;
            }
            $this->_forward('success', 'utility', 'core', array(
                'smoothboxClose' => 10,
                'parentRefresh' => 10,
                'messages' => array(Zend_Registry::get('Zend_Translate')->_(''))
            ));
        }
        $this->renderScript('admin-video/delete.tpl');
    }

    public function killAction() {

        $video_id = $this->_getParam('video_id', null);
        if ($this->getRequest()->isPost()) {
            $db = Engine_Db_Table::getDefaultAdapter();
            $db->beginTransaction();

            try {
                $siteevent = Engine_Api::_()->getItem('siteevent_video', $video_id);
                $siteevent->status = 3;
                $siteevent->save();
                $db->commit();
            } catch (Exception $e) {
                $db->rollBack();
                throw $e;
            }
        }
    }

    //ACTION OF SETTING FOR CREATING VIDEO FROM MY COMPUTER
    public function utilityAction() {

        //GET NAGIGATION
        $this->view->navigation = Engine_Api::_()->getApi('menus', 'core')
                ->getNavigation('siteevent_admin_main', array(), 'siteevent_admin_main_video');

        $this->view->subNavigation = Engine_Api::_()->getApi('menus', 'core')->getNavigation('siteevent_admin_submain', array(), 'siteevent_admin_submain_utilities_tab');

        $ffmpeg_path = Engine_Api::_()->getApi('settings', 'core')->siteevent_video_ffmpeg_path;

        $command = "$ffmpeg_path -version 2>&1";
        $this->view->version = $version = @shell_exec($command);

        $command = "$ffmpeg_path -formats 2>&1";
        $this->view->format = $format = @shell_exec($command);
    }

}