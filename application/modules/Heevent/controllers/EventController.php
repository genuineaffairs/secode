<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Heevent
 * @copyright  Copyright Hire-Experts LLC
 * @license    http://www.hire-experts.com
 * @version    $Id: EventController.php 19.10.13 08:20 jungar $
 * @author     Jungar
 */

/**
 * @category   Application_Extensions
 * @package    Heevent
 * @copyright  Copyright Hire-Experts LLC
 * @license    http://www.hire-experts.com
 */

class Heevent_EventController extends Core_Controller_Action_Standard
{
  public function init()
  {
    $id = $this->_getParam('event_id', $this->_getParam('id', null));
    if( $id )
    {
      $event = Engine_Api::_()->getItem('event', $id);
      if( $event )
      {
        Engine_Api::_()->core()->setSubject($event);
      }
    }
  }
  
  public function editAction()
  {
    $event_id = $this->getRequest()->getParam('event_id');
    $event = Engine_Api::_()->getItem('event', $event_id);
    $viewer = Engine_Api::_()->user()->getViewer();
    if( !($this->_helper->requireAuth()->setAuthParams(null, null, 'edit')->isValid() || $event->isOwner($viewer)) ) {
      return;
    }

    // Create form
    $this->view->event = $event = Engine_Api::_()->core()->getSubject();
    if($event->getEventStatusPayment()){
      $this->view->form = $form = new Heevent_Form_Admin_Create(array('parent_type' => $event->parent_type, 'parent_id'=>$event->parent_id));
    }else{
      $this->view->form = $form = new Heevent_Form_Create(array('parent_type' => $event->parent_type, 'parent_id'=>$event->parent_id));
    }

    $form->setTitle('Edit Event');

    // Populate with categories
    $categories = Engine_Api::_()->getDbtable('categories', 'event')->getCategoriesAssoc();
    asort($categories, SORT_LOCALE_STRING);
    $categoryOptions = array('0' => '');
    foreach( $categories as $k => $v ) {
      $categoryOptions[$k] = $v;
    }
    if (sizeof($categoryOptions) <= 1) {
      $form->removeElement('category_id');
    } else {
      $form->category_id->setMultiOptions($categoryOptions);
    }
    if($event->getEventStatusPayment()){
    $t=  Engine_Api::_()->getDbTable('tickets','heevent');
    $tt = $t->fetchRow($t->select()->where('event_id = ?', $event->getIdentity()));
    if($tt['ticket_price'] == -1){
      $tt['ticket_price']=0;
    }
    $form->ticket_price->setValue($tt['ticket_price']);
    $form->ticket_count->setValue($tt['ticket_count']);
    }
    if( !$this->getRequest()->isPost() ) {
      // Populate auth
      $auth = Engine_Api::_()->authorization()->context;

      if( $event->parent_type == 'group' ) {
        $roles = array('owner', 'member', 'parent_member', 'registered', 'everyone');
      } else {
        $roles = array('owner', 'member', 'owner_member', 'owner_member_member', 'owner_network', 'registered', 'everyone');
      }

      foreach( $roles as $role ) {
        if( isset($form->auth_view->options[$role]) && $auth->isAllowed($event, $role, 'view') ) {
          $form->auth_view->setValue($role);
        }
        if( isset($form->auth_comment->options[$role]) && $auth->isAllowed($event, $role, 'comment') ) {
          $form->auth_comment->setValue($role);
        }
        if( isset($form->auth_photo->options[$role]) && $auth->isAllowed($event, $role, 'photo') ) {
          $form->auth_photo->setValue($role);
        }
      }
      $form->auth_invite->setValue($auth->isAllowed($event, 'member', 'invite'));
      $form->populate($event);

      // Convert and re-populate times
      $start = strtotime($event->starttime);
      $end = strtotime($event->endtime);
      $oldTz = date_default_timezone_get();
      date_default_timezone_set($viewer->timezone);
      $start = date('Y-m-d H:i:s', $start);
      $end = date('Y-m-d H:i:s', $end);
      date_default_timezone_set($oldTz);

      $form->populate(array(
        'starttime' => $start,
        'endtime' => $end,
      ));
      return;
    }

    if( !$form->isValid($this->getRequest()->getPost()) ) {
      $vals = $form->getValues();
      $form->populate($event);
      $form->populate($vals);
      return;
    }


    // Process
    $values = $form->getValues();

    // Convert times
    $oldTz = date_default_timezone_get();
    date_default_timezone_set($viewer->timezone);
    $start = strtotime($values['starttime']);
    $end = strtotime($values['endtime']);
    date_default_timezone_set($oldTz);
    $values['starttime'] = date('Y-m-d H:i:s', $start);
    $values['endtime'] = date('Y-m-d H:i:s', $end);
    
    // Check parent
    if( !isset($values['host']) && $event->parent_type == 'group' && Engine_Api::_()->hasItemType('group') ) {
     $group = Engine_Api::_()->getItem('group', $event->parent_id);
     $values['host']  = $group->getTitle();
    }
    // Process
    $db = Engine_Api::_()->getItemTable('event')->getAdapter();
    $db->beginTransaction();

    try
    {
      // Set event info
        // Set event info
        if($values['photo_id'] == $event->photo_id){ unset($values['photo_id']);}
        if( !empty($values['photo']) ) {
            $event->setPhoto($form->photo);
            $values['photo_id'] = $event->photo_id;

        } elseif ($values['photo_id'] && $values['photo_id'] != $event->photo_id ){
            $event->setPhoto(Engine_Api::_()->getItem('storage_file', $values['photo_id']));
        }
        if($values['ticket_price']=='' || !is_numeric($values['ticket_price']) || $values['ticket_price']==0 ){
            $values['ticket_price']= -1;
        }
        if($values['ticket_count']=='' || !is_numeric($values['ticket_count'])){
            $values['ticket_count']= -1;
        }

        $ticket = array(
            'ticket_price'=> $values['ticket_price'],
            'ticket_count'=> $values['ticket_count']
        );
     // unset($values['photo_id']);
      $event->setFromArray($values);
      $event->save();
      $event->setTickets($ticket);
      $event->setParams($values['heevent_params']);


      unset($values['ticket_price']);
      unset($values['ticket_count']);

      // Process privacy
      $auth = Engine_Api::_()->authorization()->context;

      if( $event->parent_type == 'group' ) {
        $roles = array('owner', 'member', 'parent_member', 'registered', 'everyone');
      } else {
        $roles = array('owner', 'member', 'owner_member', 'owner_member_member', 'owner_network', 'registered', 'everyone');
      }

      $viewMax = array_search($values['auth_view'], $roles);
      $commentMax = array_search($values['auth_comment'], $roles);
      $photoMax = array_search($values['auth_photo'], $roles);

      foreach( $roles as $i => $role ) {
        $auth->setAllowed($event, $role, 'view',    ($i <= $viewMax));
        $auth->setAllowed($event, $role, 'comment', ($i <= $commentMax));
        $auth->setAllowed($event, $role, 'photo',   ($i <= $photoMax));
      }

      $auth->setAllowed($event, 'member', 'invite', $values['auth_invite']);

      // Commit
      $db->commit();
    }

    catch( Engine_Image_Exception $e )
    {
      $db->rollBack();
      $form->addError(Zend_Registry::get('Zend_Translate')->_('The image you selected was too large.'));
    }

    catch( Exception $e )
    {
      $db->rollBack();
      throw $e;
    }


    $db->beginTransaction();
    try {
      // Rebuild privacy
      $actionTable = Engine_Api::_()->getDbtable('actions', 'activity');
      foreach( $actionTable->getActionsByObject($event) as $action ) {
        $actionTable->resetActivityBindings($action);
      }

      $db->commit();
    }
    catch( Exception $e )
    {
      $db->rollBack();
      throw $e;
    }

  // Redirect
    if( $this->_getParam('ref') === 'profile' ) {
      $this->_redirectCustom($event);
    } else {
      $this->_redirectCustom(array('route' => 'event_general', 'action' => 'manage'));
    }
  }


  public function inviteAction()
  {

    if( !$this->_helper->requireUser()->isValid() ) return;
    if( !$this->_helper->requireSubject('event')->isValid() ) return;
    // @todo auth

    // Prepare data
    $viewer = Engine_Api::_()->user()->getViewer();
    $this->view->event = $event = Engine_Api::_()->core()->getSubject();
    $this->view->friends = $friends = $viewer->membership()->getMembers();

    // Prepare form
    $this->view->form = $form = new Event_Form_Invite();

    $count = 0;
    foreach( $friends as $friend )
    {
      if( $event->membership()->isMember($friend, null) ) continue;
      $form->users->addMultiOption($friend->getIdentity(), $friend->getTitle());
      $count++;
    }
    $this->view->count = $count;
    // Not posting
    if( !$this->getRequest()->isPost() )
    {
      return;
    }
    if( !$form->isValid($this->getRequest()->getPost()) )
      {
      return;
    }

   // Process
    $table = $event->getTable();
    $db = $table->getAdapter();
    $db->beginTransaction();

    try
    {
      $usersIds = $form->getValue('users');
      
      $notifyApi = Engine_Api::_()->getDbtable('notifications', 'activity');
      foreach( $friends as $friend )
      {
        if( !in_array($friend->getIdentity(), $usersIds) )
        {
          continue;
        }

        $event->membership()->addMember($friend)
          ->setResourceApproved($friend);

        $notifyApi->addNotification($friend, $viewer, $event, 'event_invite');
      }


      $db->commit();
    }

    catch( Exception $e )
    {
      $db->rollBack();
      throw $e;
    }
    
    return $this->_forward('success', 'utility', 'core', array(
      'messages' => array(Zend_Registry::get('Zend_Translate')->_('HEEVENT_Members are invited')),
      'layout' => 'default-simple',
      'parentRefresh' => true,
    ));
  }

 public function styleAction()
  {
    if( !$this->_helper->requireAuth()->setAuthParams(null, null, 'edit')->isValid() ) return;
    if( !$this->_helper->requireAuth()->setAuthParams(null, null, 'style')->isValid() ) return;
    
    $user = Engine_Api::_()->user()->getViewer();
    $event = Engine_Api::_()->core()->getSubject('event');

    // Make form
    $this->view->form = $form = new Event_Form_Style();

    // Get current row
    $table = Engine_Api::_()->getDbtable('styles', 'core');
    $select = $table->select()
      ->where('type = ?', 'event')
      ->where('id = ?', $event->getIdentity())
      ->limit(1);

    $row = $table->fetchRow($select);

    // Check post
    if( !$this->getRequest()->isPost() )
    {
      $form->populate(array(
        'style' => ( null === $row ? '' : $row->style )
      ));
      return;
    }

    if( !$form->isValid($this->getRequest()->getPost()) )
    {
      return;
    }

    // Cool! Process
    $style = $form->getValue('style');

    // Save
    if( null == $row )
    {
      $row = $table->createRow();
      $row->type = 'event';
      $row->id = $event->getIdentity();
    }

    $row->style = $style;
    $row->save();

    $this->view->draft = true;
    $this->view->message = Zend_Registry::get('Zend_Translate')->_('Your changes have been saved.');
    $this->_forward('success', 'utility', 'core', array(
        'smoothboxClose' => true,
        'parentRefresh' => false,
        'messages' => array(Zend_Registry::get('Zend_Translate')->_('Your changes have been saved.'))
    ));
  }


  public function deleteAction()
  {

    $viewer = Engine_Api::_()->user()->getViewer();
    $event_id = $this->getRequest()->getParam('event_id');
    $event = Engine_Api::_()->getItem('event', $event_id);
    if( !$this->_helper->requireAuth()->setAuthParams($event, null, 'delete')->isValid()) return;

    // In smoothbox
    $this->_helper->layout->setLayout('default-simple');
    
    // Make form
    $this->view->form = $form = new Event_Form_Delete();

    if( !$event )
    {
      $this->view->status = false;
      $this->view->error = Zend_Registry::get('Zend_Translate')->_("Event doesn't exists or not authorized to delete");
      return;
    }

    if( !$this->getRequest()->isPost() )
    {
      $this->view->status = false;
      $this->view->error = Zend_Registry::get('Zend_Translate')->_('Invalid request method');
      return;
    }

    $db = $event->getTable()->getAdapter();
    $db->beginTransaction();

    try
    {
      $event->delete();
      $db->commit();
    }
    catch( Exception $e )
    {
      $db->rollBack();
      throw $e;
    }
    
    $this->view->status = true;
    $this->view->message = Zend_Registry::get('Zend_Translate')->_('The selected event has been deleted.');
    return $this->_forward('success' ,'utility', 'core', array(
      'parentRedirect' => Zend_Controller_Front::getInstance()->getRouter()->assemble(array('action' => 'manage'), 'event_general', true),
      'messages' => Array($this->view->message)
    ));
  }

  public function ticketsAction()
  {
    $viewer = Engine_Api::_()->user()->getViewer();


    if(!$viewer->getIdentity())
    {
      return $this->setNoRender();
    }


    $tblCard = Engine_Api::_()->getDbtable('cards', 'heevent');
    $Cardname = $tblCard->info('name');
    $tblevent = Engine_Api::_()->getDbtable('events', 'heevent');
    $Ename = $tblevent->info('name');
    $fetch = $tblCard->select()->from(array('c'=>$Cardname))
      ->joinLeft(array('e' => $Ename), 'e.event_id =  c.event_id', array())->where('c.state = ?','okay');
    $this->view->active_past = 1;
    $select = $tblCard->fetchAll($fetch);
    $cardArray = $select->toArray();
    $this->view->paginator = $paginator = Zend_Paginator::factory($cardArray);
    $paginator->setItemCountPerPage(30);

  }







}