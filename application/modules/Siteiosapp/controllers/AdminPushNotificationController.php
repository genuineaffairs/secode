<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Siteiosapp
 * @copyright  Copyright 2015-2016 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    AdminPushNotificationController.php 2015-10-01 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Siteiosapp_AdminPushNotificationController extends Core_Controller_Action_Admin {

    public function init() {
        $this->view->navigation = Engine_Api::_()->getApi('menus', 'core')->getNavigation('siteiosapp_admin_main', array(), 'siteiosapp_admin_notifications');
    }

    public function indexAction() {
        // Build the different notification types
        $modules = Engine_Api::_()->getDbtable('modules', 'core')->getModulesAssoc();
        $notificationTypes = Engine_Api::_()->getDbtable('notificationTypes', 'siteiosapp')->getNotificationTypes();
        $notificationSettings = Engine_Api::_()->getDbtable('notificationTypes', 'siteiosapp')->getDefaultPushNotifications();

        $notificationTypesAssoc = array();
        $notificationSettingsAssoc = array();
        foreach ($notificationTypes as $type) {
            if (in_array($type->module, array('core', 'activity', 'fields', 'authorization', 'messages', 'user'))) {
                $elementName = 'general';
                $category = 'General';
            } else if (isset($modules[$type->module])) {
                $elementName = preg_replace('/[^a-zA-Z0-9]+/', '-', $type->module);
                $category = $modules[$type->module]->title;
            } else {
                $elementName = 'misc';
                $category = 'Misc';
            }

            $notificationTypesAssoc[$elementName]['category'] = $category;
            $notificationTypesAssoc[$elementName]['types'][$type->type] = 'ACTIVITY_TYPE_' . strtoupper($type->type);

            if (in_array($type->type, $notificationSettings)) {
                $notificationSettingsAssoc[$elementName][] = $type->type;
            }
        }

        ksort($notificationTypesAssoc);

        $notificationTypesAssoc = array_filter(array_merge(array(
            'general' => array(),
            'misc' => array(),
                        ), $notificationTypesAssoc));


        $this->view->form = $form = new Engine_Form(array(
            'title' => 'Push Notification Settings',
            'description' => "Choose Push notification types which you want to enable for app.",
        ));

        foreach ($notificationTypesAssoc as $elementName => $info) {
            //MAKE SOME OF THE PUSH NOTIFICATION SETTINGS ENABLE AT FIRST TIME.
            $preSelectedNotification = array('general', 'event', 'group');
            if (in_array($elementName, $preSelectedNotification)) {
                $notificationsTypesTable = Engine_Api::_()->getDbtable('notificationTypes', 'activity');
                foreach ($info['types'] as $infoType => $type) {
                    $where = array(
                        '`type`' => $infoType,
                    );
                }

                $notificationsTypesTable->update(array('siteiosapp_enable_push' => 1), $where);
            }

            $form->addElement('MultiCheckbox', $elementName, array(
                'label' => $info['category'],
                'multiOptions' => $info['types'],
                'value' => (array) @$notificationSettingsAssoc[$elementName],
            ));
        }

        // init submit
        $form->addElement('Button', 'submit', array(
            'label' => 'Save Changes',
            'type' => 'submit',
            'ignore' => true,
        ));

        // Check method
        if (!$this->getRequest()->isPost()) {
            return;
        }

        if (!$form->isValid($this->getRequest()->getPost())) {
            return;
        }

        $values = array();
        foreach ($form->getValues() as $key => $value) {
            if (!is_array($value))
                continue;

            foreach ($value as $skey => $svalue) {
                if (!isset($notificationTypesAssoc[$key]['types'][$svalue])) {
                    continue;
                }
                $values[] = $svalue;
            }
        }

        include_once APPLICATION_PATH . '/application/modules/Siteiosapp/controllers/license/license2.php';
        $form->addNotice('Your changes have been saved.');
    }

    public function typesAction() {
        $selectedType = $this->_getParam('type');

        // Make form
        $this->view->form = $form = new Siteiosapp_Form_Admin_PushNotification_Type();

        // Populate settings
        $notificationSettings = Engine_Api::_()->getDbtable('notificationTypes', 'siteiosapp')->getDefaultPushNotifications();
        $multiOptions = array();
        foreach ($notificationSettings as $notificationType) {
            $multiOptions[$notificationType] = 'ACTIVITY_TYPE_' . strtoupper($notificationType);
        }
        $this->view->countNotification = count($multiOptions);
        if (empty($this->view->countNotification)) {
            return;
        }
        $form->type->setMultiOptions($multiOptions);

        if (!$selectedType || !isset($multiOptions[$selectedType])) {
            $selectedType = key($multiOptions);
        }

        $selectedTypeObject = Engine_Api::_()->getDbtable('notificationTypes', 'siteiosapp')->getNotificationType($selectedType);

        $form->populate($selectedTypeObject->toArray());
        // Process mulitcheckbox
        $siteapiios_pushtype = array();
        if (4 & (int) $selectedTypeObject->siteiosapp_pushtype) {
            $siteapiios_pushtype[] = 4;
        }
        if (2 & (int) $selectedTypeObject->siteiosapp_pushtype) {
            $siteapiios_pushtype[] = 2;
        }
        if (1 & (int) $selectedTypeObject->siteiosapp_pushtype) {
            $siteapiios_pushtype[] = 1;
        }

        $form->siteiosapp_pushtype->setValue($siteapiios_pushtype);

        if (!$this->getRequest()->isPost()) {
            return;
        }
        if (!$form->isValid($this->getRequest()->getPost())) {
            return;
        }


        // Process
        $values = $form->getValues();
        $values['siteiosapp_pushtype'] = array_sum($values['siteiosapp_pushtype']);        

        // Check type
        if (!$selectedTypeObject ||
                !isset($multiOptions[$selectedTypeObject->type]) ||
                $selectedTypeObject->type != $values['type']) {
            return $form->addError('Please select a valid type');
        }

        unset($values['type']);

        // Save
        $selectedTypeObject->setFromArray($values);
        $selectedTypeObject->save();

        $form->addNotice('Your changes have been saved.');
    }

    public function sendAction() {
        // Make form
        $this->view->form = $form = new Siteiosapp_Form_Admin_PushNotification_Send();

        $this->view->navigation = Engine_Api::_()->getApi('menus', 'core')->getNavigation('siteiosapp_admin_main', array(), 'siteiosapp_admin_send_notifications');

        if (!$this->getRequest()->isPost()) {
            return;
        }
        if (!$form->isValid($this->getRequest()->getPost())) {
            return;
        }

        // Process
        $values = $form->getValues();
        $params['title'] = $values['notification_title'];
        $params['message'] = $values['notification_subject'];

        if ($values['send_to'] == 'registered') {
            $apnUsers = Engine_Api::_()->getDbtable('apnusers', 'siteiosapp')->getUsers();
        } elseif ($values['send_to'] == 'network') {
            if (empty($values['network'])) {
                $form->addError('please select atleast one Network - it is required');
                return;
            }

            $apnUsers = Engine_Api::_()->getDbtable('apnusers', 'siteiosapp')->getNetworkBasedUsers($values['network']);
        } elseif ($values['send_to'] == 'member_level') {
            if (empty($values['member_level'])) {
                $form->addError('please select atleast one Member Level - it is required');
                return;
            }

            $apnUsers = Engine_Api::_()->getDbtable('apnusers', 'siteiosapp')->getLevelBasedUsers($values['member_level']);
        } elseif ($values['send_to'] == 'specific_user') {
            if (empty($values['toValues'])) {
                $form->addError('please enter atleast one user name - it is required');
                return;
            }

            $apnUsers = Engine_Api::_()->getDbtable('apnusers', 'siteiosapp')->getUsers(array('user_ids' => explode(',', $values['toValues'])));
        }

        // Send push notification to client.
        include_once APPLICATION_PATH . '/application/modules/Siteiosapp/controllers/license/license2.php';


        $form->addNotice('Your push notification message have been sent.');
    }

    public function suggestAction() {
        $data = array();
        $text = $this->_getParam('search', $this->_getParam('value'));
        $limit = (int) $this->_getParam('limit', 10);
        $allApnUsers = Engine_Api::_()->getDbtable('apnusers', 'siteiosapp')->getAllApnBasedUsers($text, $limit);
        foreach ($allApnUsers as $apnUser) {
            $data[] = array(
                'type' => 'user',
                'id' => $apnUser->getIdentity(),
                'guid' => $apnUser->getGuid(),
                'label' => $apnUser->getTitle(),
                'photo' => $this->view->itemPhoto($apnUser, 'thumb.icon'),
                'url' => $apnUser->getHref(),
            );
        }

        if ($this->_getParam('sendNow', true)) {
            return $this->_helper->json($data);
        } else {
            $this->_helper->viewRenderer->setNoRender(true);
            $data = Zend_Json::encode($data);
            $this->getResponse()->setBody($data);
        }
    }

}
